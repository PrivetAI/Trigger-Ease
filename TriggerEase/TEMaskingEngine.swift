import Foundation
import AVFoundation
import Combine

// The entire audio surface of Trigger Ease: six presets, one master level, one sleep timer.
// Deliberately small. There is no spectrum display, no per-layer mixing and no frequency control.

enum TEMaskPreset: String, CaseIterable, Identifiable {
    case none
    case brown
    case rain
    case fan
    case cafe
    case white
    case rumble

    var id: String { rawValue }

    /// The six real presets. `.none` is a plan option, not a sound.
    static var playable: [TEMaskPreset] { [.brown, .rain, .fan, .cafe, .white, .rumble] }

    var title: String {
        switch self {
        case .none: return "No masking"
        case .brown: return "Brown noise"
        case .rain: return "Rain"
        case .fan: return "Fan"
        case .cafe: return "Café murmur"
        case .white: return "White noise"
        case .rumble: return "Low rumble"
        }
    }

    var blurb: String {
        switch self {
        case .none: return "No sound. Some situations are better handled with position alone."
        case .brown: return "Deep and even, with the harshness taken out. The usual first choice for masking speech and chewing."
        case .rain: return "Steady rainfall. Slightly livelier than brown noise, which some people find easier to leave running."
        case .fan: return "A soft mechanical whirr with a slow cycle, close to a desk fan across a room."
        case .cafe: return "A low unintelligible murmur. Useful when total blankness feels wrong but words would distract."
        case .white: return "Flat and bright. The most effective against high, sharp triggers and the most tiring over long periods."
        case .rumble: return "Very low and continuous, like distant traffic. Good under bass through a wall, and quiet enough for sleep."
        }
    }
}

final class TEMaskingEngine: ObservableObject {

    @Published private(set) var isPlaying = false
    @Published private(set) var activePreset: TEMaskPreset = .brown
    @Published private(set) var sleepRemainingSeconds: Int = 0
    @Published private(set) var sleepTimerActive = false
    @Published var lastError: String?

    /// 0...1. Applied as a gentle curve so the low end of the slider is usable.
    var level: Double = 0.35 {
        didSet { updateTargetGain() }
    }

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var sampleRate: Double = 44100

    // Render-thread state. Plain values, written from the main thread only between renders.
    private var preset: TEMaskPreset = .brown
    private var targetGain: Float = 0
    private var currentGain: Float = 0
    private var gainStep: Float = 0.0001

    // Filter state
    private var brownState: Float = 0
    private var lowState1: Float = 0
    private var lowState2: Float = 0
    private var highState: Float = 0
    private var highPrev: Float = 0
    private var modPhase: Float = 0
    private var murmurEnv: Float = 0.4
    private var murmurTarget: Float = 0.4
    private var murmurCountdown: Int = 0
    private var rngState: UInt32 = 0x9E3779B9

    private var sleepTimer: Timer?
    private var fadeOutWorkItem: DispatchWorkItem?
    /// True between `play` and `stop`. Drives the gain target independently of the published flag.
    private var wantsSound = false

    init() {
        registerObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        sleepTimer?.invalidate()
    }

    // MARK: - Public control

    func play(_ preset: TEMaskPreset, sleepMinutes: Int?) {
        guard preset != .none else { stop(); return }
        fadeOutWorkItem?.cancel()
        fadeOutWorkItem = nil
        activePreset = preset
        self.preset = preset
        resetFilters()
        do {
            try configureSession()
            try startEngineIfNeeded()
        } catch {
            lastError = "Audio could not start on this device."
            isPlaying = false
            return
        }
        lastError = nil
        // Ramp in over roughly 300 ms rather than snapping to level.
        currentGain = 0
        wantsSound = true
        updateTargetGain()
        gainStep = max(0.000005, Float(teSafeDivide(Double(targetGain), sampleRate * 0.3, fallback: 0.0001)))
        isPlaying = true
        startSleepTimer(minutes: sleepMinutes)
    }

    func stop() {
        fadeOutWorkItem?.cancel()
        cancelSleepTimer()
        wantsSound = false
        guard isPlaying else {
            teardown()
            return
        }
        // Fade out, then tear the engine down.
        targetGain = 0
        gainStep = max(0.000005, Float(teSafeDivide(Double(currentGain), sampleRate * 0.35, fallback: 0.0002)))
        isPlaying = false
        let item = DispatchWorkItem { [weak self] in self?.teardown() }
        fadeOutWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: item)
    }

    func toggle(_ preset: TEMaskPreset, sleepMinutes: Int?) {
        if isPlaying && activePreset == preset {
            stop()
        } else {
            play(preset, sleepMinutes: sleepMinutes)
        }
    }

    func extendSleepTimer(minutes: Int) {
        startSleepTimer(minutes: minutes)
    }

    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerActive = false
        sleepRemainingSeconds = 0
    }

    // MARK: - Session and engine

    private func configureSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true, options: [])
        sampleRate = session.sampleRate > 0 ? session.sampleRate : 44100
    }

    private func startEngineIfNeeded() throws {
        if sourceNode == nil {
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
            guard let format = format else { throw TEMaskError.formatUnavailable }
            let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
                guard let self = self else { return noErr }
                let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for frame in 0..<Int(frameCount) {
                    let value = self.nextSample()
                    for buffer in buffers {
                        guard let pointer = buffer.mData?.assumingMemoryBound(to: Float.self) else { continue }
                        let channelFrames = Int(buffer.mDataByteSize) / MemoryLayout<Float>.size
                        if frame < channelFrames { pointer[frame] = value }
                    }
                }
                return noErr
            }
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: format)
            sourceNode = node
        }
        if !engine.isRunning {
            engine.prepare()
            try engine.start()
        }
    }

    private func teardown() {
        if engine.isRunning { engine.stop() }
        if let node = sourceNode {
            engine.disconnectNodeOutput(node)
            engine.detach(node)
            sourceNode = nil
        }
        currentGain = 0
        targetGain = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    private func updateTargetGain() {
        guard wantsSound else {
            targetGain = 0
            return
        }
        let clamped = max(0, min(1, level))
        // A squared curve keeps the bottom of the slider genuinely quiet, and the ceiling is
        // held well below full scale on purpose — this is a floor, not a wall of sound.
        targetGain = Float(clamped * clamped * 0.55)
    }

    private func resetFilters() {
        brownState = 0
        lowState1 = 0
        lowState2 = 0
        highState = 0
        highPrev = 0
        modPhase = 0
        murmurEnv = 0.4
        murmurTarget = 0.4
        murmurCountdown = 0
    }

    // MARK: - Sleep timer

    private func startSleepTimer(minutes: Int?) {
        sleepTimer?.invalidate()
        guard let minutes = minutes, minutes > 0 else {
            sleepTimer = nil
            sleepTimerActive = false
            sleepRemainingSeconds = 0
            return
        }
        restoreSleepTimer(seconds: minutes * 60)
    }

    /// Runs the countdown from an exact number of seconds. Used to carry a timer across an
    /// engine restart without rounding it back up to whole minutes.
    private func restoreSleepTimer(seconds: Int) {
        sleepTimer?.invalidate()
        guard seconds > 0 else {
            sleepTimer = nil
            sleepTimerActive = false
            sleepRemainingSeconds = 0
            return
        }
        sleepRemainingSeconds = seconds
        sleepTimerActive = true
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.sleepRemainingSeconds <= 1 {
                self.sleepRemainingSeconds = 0
                self.sleepTimerActive = false
                self.sleepTimer?.invalidate()
                self.sleepTimer = nil
                self.stop()
            } else {
                self.sleepRemainingSeconds -= 1
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        sleepTimer = timer
    }

    // MARK: - Interruptions and route changes

    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleEngineConfigChange(_:)),
            name: .AVAudioEngineConfigurationChange, object: engine)
    }

    @objc private func handleInterruption(_ note: Notification) {
        guard let info = note.userInfo,
              let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        DispatchQueue.main.async {
            switch type {
            case .began:
                if self.isPlaying { self.stop() }
            case .ended:
                // Deliberately do not auto-resume: unexpected sound is the last thing this
                // particular user wants after a phone call.
                break
            @unknown default:
                break
            }
        }
    }

    @objc private func handleRouteChange(_ note: Notification) {
        guard let info = note.userInfo,
              let raw = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: raw) else { return }
        if reason == .oldDeviceUnavailable {
            DispatchQueue.main.async { self.stop() }
        }
    }

    @objc private func handleEngineConfigChange(_ note: Notification) {
        DispatchQueue.main.async {
            guard self.isPlaying else { return }
            let preset = self.activePreset
            // Connecting or disconnecting headphones fires this. Restarting the engine must not
            // silently cancel a running sleep timer, or the sound plays all night.
            let hadTimer = self.sleepTimerActive
            let remaining = self.sleepRemainingSeconds
            self.teardown()
            self.play(preset, sleepMinutes: nil)
            if hadTimer && remaining > 0 {
                self.restoreSleepTimer(seconds: remaining)
            }
        }
    }

    // MARK: - Sample generation

    /// Fast deterministic noise source. No allocation, no locking, safe to call per sample.
    private func nextRandom() -> Float {
        rngState = 1_664_525 &* rngState &+ 1_013_904_223
        let normalised = Float(rngState >> 8) / Float(1 << 24)
        return normalised * 2 - 1
    }

    private func nextSample() -> Float {
        // Move the gain towards its target one step at a time — this is the ramp and the fade.
        if currentGain < targetGain {
            currentGain = min(targetGain, currentGain + gainStep)
        } else if currentGain > targetGain {
            currentGain = max(targetGain, currentGain - gainStep)
        }
        if currentGain <= 0 { return 0 }

        let noise = nextRandom()
        var value: Float

        switch preset {
        case .none, .white:
            // Gentle single-pole smoothing keeps white noise from sounding digitally harsh.
            lowState1 += 0.82 * (noise - lowState1)
            value = noise * 0.7 + lowState1 * 0.3

        case .brown:
            brownState = (brownState + 0.021 * noise)
            if brownState > 1 { brownState = 1 }
            if brownState < -1 { brownState = -1 }
            brownState *= 0.9985
            value = brownState * 3.2

        case .rumble:
            brownState = (brownState + 0.010 * noise)
            if brownState > 1 { brownState = 1 }
            if brownState < -1 { brownState = -1 }
            brownState *= 0.9993
            lowState1 += 0.020 * (brownState - lowState1)
            lowState2 += 0.020 * (lowState1 - lowState2)
            value = lowState2 * 7.5

        case .rain:
            // Band-limited hiss: remove the very low end, soften the very top, then let a slow
            // modulation open and close it slightly so it does not sit perfectly still.
            highState += 0.30 * (noise - highState)
            let high = noise - highState
            lowState1 += 0.55 * (high - lowState1)
            modPhase += Float(teSafeDivide(2 * Double.pi * 0.13, sampleRate, fallback: 0.00002))
            if modPhase > Float(2 * Double.pi) { modPhase -= Float(2 * Double.pi) }
            let modulation = 0.82 + 0.18 * sin(modPhase)
            value = lowState1 * 1.5 * modulation

        case .fan:
            lowState1 += 0.10 * (noise - lowState1)
            lowState2 += 0.10 * (lowState1 - lowState2)
            modPhase += Float(teSafeDivide(2 * Double.pi * 7.5, sampleRate, fallback: 0.001))
            if modPhase > Float(2 * Double.pi) { modPhase -= Float(2 * Double.pi) }
            let whirr = 0.90 + 0.10 * sin(modPhase)
            value = lowState2 * 4.6 * whirr

        case .cafe:
            // Low-passed noise under a slowly wandering envelope reads as a room of voices
            // with the words removed. No speech is synthesised.
            if murmurCountdown <= 0 {
                murmurTarget = 0.35 + 0.5 * abs(nextRandom())
                murmurCountdown = Int(sampleRate * Double(0.25 + 0.6 * abs(nextRandom())))
            }
            murmurCountdown -= 1
            murmurEnv += 0.00004 * (murmurTarget - murmurEnv)
            highState += 0.06 * (noise - highState)
            let voiceBand = highState - highPrev
            highPrev += 0.35 * (highState - highPrev)
            lowState1 += 0.28 * (voiceBand - lowState1)
            value = lowState1 * 9.0 * murmurEnv
        }

        if value > 1 { value = 1 }
        if value < -1 { value = -1 }
        return value * currentGain
    }
}

enum TEMaskError: Error {
    case formatUnavailable
}
