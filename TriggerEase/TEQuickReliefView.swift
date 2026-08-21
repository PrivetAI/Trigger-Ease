import SwiftUI
import Combine

/// Reachable from every tab. One tap starts a sixty-second guided breath, with masking optional.
struct TEQuickReliefView: View {
    let onClose: () -> Void

    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine

    @State private var running = false
    /// Wall-clock anchor for the session. Elapsed time is measured against this rather than
    /// accumulated from tick count, so a slipping run loop cannot stretch a 60 s session.
    @State private var startDate = Date()
    @State private var totalSeconds: Double = 60
    /// Only stop masking on the way out if this screen was the thing that started it.
    @State private var startedMaskingHere = false

    var body: some View {
        ZStack(alignment: .top) {
            TEPalette.sand.edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    // The animated part lives in its own view so a tick redraws the circle and
                    // its two labels, not the whole sheet.
                    TEBreathStage(running: running,
                                  startDate: startDate,
                                  totalSeconds: totalSeconds,
                                  inSeconds: inSeconds,
                                  holdSeconds: holdSeconds,
                                  outSeconds: outSeconds,
                                  size: circleSize,
                                  onFinish: { running = false })

                    HStack(spacing: 9) {
                        TEChip(title: "60 s", selected: totalSeconds == 60) { setLength(60) }
                        TEChip(title: "2 min", selected: totalSeconds == 120) { setLength(120) }
                        TEChip(title: "3 min", selected: totalSeconds == 180) { setLength(180) }
                        Spacer(minLength: 0)
                    }

                    TEPrimaryButton(title: running ? "Stop" : "Start", glyph: running ? .stop : .play) {
                        if running {
                            stop()
                        } else {
                            start()
                        }
                    }

                    maskingCard
                    paceCard
                    groundingCard

                    TEFootnote(text: "The active part of nearly every breathing exercise is a longer out-breath than in-breath. Everything else is scaffolding.")

                    TEDisclaimerCard(compact: true)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            // No TEStatusStrip here: this screen is a card sheet, so its own top safe-area inset
            // is 0 and a strip sized from the key window would cover the title and close button.
        }
        .onDisappear { if startedMaskingHere { masking.stop() } }
    }

    private var circleSize: CGFloat {
        let byWidth = TEMetrics.screenWidth - 90
        let byHeight: CGFloat = TEMetrics.isCompactHeight ? 180 : 230
        return max(140, min(byWidth, byHeight))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Quick relief")
                    .font(TEType.display(26))
                    .foregroundColor(TEPalette.ink)
                Text("Nothing to decide. Follow the shape.")
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
            }
            Spacer(minLength: 0)
            Button(action: {
                if startedMaskingHere { masking.stop() }
                onClose()
            }) {
                ZStack {
                    Circle().fill(TEPalette.card)
                    TEGlyph(kind: .close, size: 17, color: TEPalette.inkSoft, weight: 2.0)
                }
                .frame(width: 38, height: 38)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 6)
    }

    private var maskingCard: some View {
        TECard(padding: 14) {
            HStack(spacing: 11) {
                TEGlyph(kind: .volume, size: 18, color: TEPalette.moss)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Masking")
                        .font(TEType.medium(14.5))
                        .foregroundColor(TEPalette.ink)
                    Text(masking.isPlaying ? "\(masking.activePreset.title) is running" : defaultPreset.title)
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkSoft)
                }
                Spacer(minLength: 0)
                Button(action: toggleMasking) {
                    Text(masking.isPlaying ? "Stop" : "Start")
                        .font(TEType.medium(13))
                        .foregroundColor(masking.isPlaying ? TEPalette.card : TEPalette.mossDeep)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule(style: .continuous)
                                .fill(masking.isPlaying ? TEPalette.mossDeep : Color.clear)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(masking.isPlaying ? Color.clear : TEPalette.mossDeep.opacity(0.4), lineWidth: 1.2)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var paceCard: some View {
        TECard(padding: 14) {
            Text("Pace")
                .font(TEType.medium(14))
                .foregroundColor(TEPalette.ink)
            Text("In \(TEFormat.decimal(store.preferences.breathInSeconds))s · hold \(TEFormat.decimal(store.preferences.breathHoldSeconds))s · out \(TEFormat.decimal(store.preferences.breathOutSeconds))s")
                .font(TEType.body(12.5))
                .foregroundColor(TEPalette.inkSoft)
            HStack(spacing: 7) {
                paceChip(title: "4-2-6", in: 4, hold: 2, out: 6)
                paceChip(title: "Box 4-4-4", in: 4, hold: 4, out: 4)
                paceChip(title: "4-7-8", in: 4, hold: 7, out: 8)
            }
            TEFootnote(text: "Stop earlier if you feel light-headed. The point is a longer out-breath, not endurance.")
        }
    }

    private func paceChip(title: String, in inSeconds: Double, hold: Double, out: Double) -> some View {
        let active = store.preferences.breathInSeconds == inSeconds
            && store.preferences.breathHoldSeconds == hold
            && store.preferences.breathOutSeconds == out
        return TEChip(title: title, selected: active) {
            store.preferences.breathInSeconds = inSeconds
            store.preferences.breathHoldSeconds = hold
            store.preferences.breathOutSeconds = out
        }
    }

    private var groundingCard: some View {
        TECard(padding: 14, background: TEPalette.mossSoft.opacity(0.4), border: TEPalette.moss.opacity(0.3)) {
            Text("If breathing is not landing")
                .font(TEType.medium(14))
                .foregroundColor(TEPalette.mossDeep)
            Text("Five things you can see. Four you can feel. Three you can hear that are not the trigger. Two you can smell. One slow breath.")
                .font(TEType.body(13))
                .foregroundColor(TEPalette.mossDeep.opacity(0.92))
                .lineSpacing(2.5)
                .fixedSize(horizontal: false, vertical: true)
            Text("Losing the thread and starting again is not failing at it.")
                .font(TEType.body(12))
                .foregroundColor(TEPalette.mossDeep.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Cycle maths

    private var inSeconds: Double { max(1, store.preferences.breathInSeconds) }
    private var holdSeconds: Double { max(0, store.preferences.breathHoldSeconds) }
    private var outSeconds: Double { max(1, store.preferences.breathOutSeconds) }

    private var defaultPreset: TEMaskPreset {
        let stored = TEMaskPreset(rawValue: store.preferences.defaultMasking) ?? .brown
        return stored == .none ? .brown : stored
    }

    // MARK: - Behaviour

    private func setLength(_ seconds: Double) {
        totalSeconds = seconds
        if running { startDate = Date() }
    }

    private func start() {
        startDate = Date()
        running = true
    }

    private func stop() {
        running = false
    }

    private func toggleMasking() {
        if masking.isPlaying {
            masking.stop()
            startedMaskingHere = false
        } else {
            masking.level = store.preferences.masterLevel
            masking.play(defaultPreset, sleepMinutes: nil)
            startedMaskingHere = true
        }
    }
}

enum TEBreathPhase {
    case ready
    case inhale
    case hold
    case exhale
}

/// The only part of the quick relief sheet that changes while a session runs. It owns the tick
/// so the cards around it are not rebuilt ten times a second.
struct TEBreathStage: View {
    let running: Bool
    /// Wall-clock start of the current session. Elapsed time is derived from it, never accumulated.
    let startDate: Date
    let totalSeconds: Double
    let inSeconds: Double
    let holdSeconds: Double
    let outSeconds: Double
    let size: CGFloat
    let onFinish: () -> Void

    @State private var elapsed: Double = 0

    private let ticker = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 10) {
            TEBreathCircle(phase: phase, phaseProgress: phaseProgress, size: size)
            Text(phaseLabel)
                .font(TEType.display(21))
                .foregroundColor(TEPalette.mossDeep)
            Text(running ? "\(Int(max(0, totalSeconds - elapsed).rounded())) seconds left" : "\(Int(totalSeconds)) seconds")
                .font(TEType.body(13))
                .foregroundColor(TEPalette.inkFaint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .onReceive(ticker) { _ in tick() }
        .onChange(of: startDate) { _ in elapsed = 0 }
        .onChange(of: running) { _ in elapsed = 0 }
    }

    private func tick() {
        guard running else { return }
        let value = Date().timeIntervalSince(startDate)
        if value >= totalSeconds {
            elapsed = 0
            onFinish()
            return
        }
        elapsed = max(0, value)
    }

    private var cycleLength: Double { inSeconds + holdSeconds + outSeconds }

    private var cyclePosition: Double {
        guard cycleLength > 0 else { return 0 }
        return elapsed.truncatingRemainder(dividingBy: cycleLength)
    }

    private var phase: TEBreathPhase {
        guard running else { return .ready }
        let position = cyclePosition
        if position < inSeconds { return .inhale }
        if position < inSeconds + holdSeconds { return .hold }
        return .exhale
    }

    private var phaseProgress: Double {
        guard running else { return 0 }
        let position = cyclePosition
        switch phase {
        case .ready: return 0
        case .inhale: return min(1, teSafeDivide(position, inSeconds))
        case .hold: return 1
        case .exhale: return min(1, teSafeDivide(position - inSeconds - holdSeconds, outSeconds))
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .ready: return "Ready when you are"
        case .inhale: return "Breathe in"
        case .hold: return "Hold"
        case .exhale: return "Breathe out"
        }
    }
}

/// The breathing animation. Drawn entirely in Canvas.
struct TEBreathCircle: View {
    let phase: TEBreathPhase
    let phaseProgress: Double
    let size: CGFloat

    var body: some View {
        Canvas { context, _ in
            draw(&context, side: size)
        }
        .frame(width: size, height: size)
    }

    private func draw(_ context: inout GraphicsContext, side: CGFloat) {
        let centre = CGPoint(x: side / 2, y: side / 2)
        let minRadius = side * 0.20
        let maxRadius = side * 0.44

        let openness: CGFloat
        switch phase {
        case .ready: openness = 0.35
        case .inhale: openness = CGFloat(eased(phaseProgress))
        case .hold: openness = 1
        case .exhale: openness = CGFloat(1 - eased(phaseProgress))
        }
        let radius = minRadius + (maxRadius - minRadius) * openness

        // Static guide rings
        for step in 0..<3 {
            let r = minRadius + (maxRadius - minRadius) * CGFloat(step) / 2
            var ring = Path()
            ring.addEllipse(in: CGRect(x: centre.x - r, y: centre.y - r, width: r * 2, height: r * 2))
            context.stroke(ring, with: .color(TEPalette.line.opacity(0.7)), style: StrokeStyle(lineWidth: 0.8))
        }

        // The breathing petal
        var petal = Path()
        petal.addEllipse(in: CGRect(x: centre.x - radius, y: centre.y - radius,
                                    width: radius * 2, height: radius * 2))
        context.fill(petal, with: .color(TEPalette.mossSoft.opacity(0.55)))
        context.stroke(petal, with: .color(TEPalette.moss), style: StrokeStyle(lineWidth: 2))

        // Four quiet leaves around it so it is not a plain circle
        for index in 0..<4 {
            let angle = Double(index) * Double.pi / 2 + Double.pi / 4
            let tip = CGPoint(x: centre.x + CGFloat(cos(angle)) * (radius + side * 0.055),
                              y: centre.y + CGFloat(sin(angle)) * (radius + side * 0.055))
            let base = CGPoint(x: centre.x + CGFloat(cos(angle)) * radius * 0.7,
                               y: centre.y + CGFloat(sin(angle)) * radius * 0.7)
            var leaf = Path()
            leaf.move(to: base)
            leaf.addQuadCurve(to: tip,
                              control: CGPoint(x: base.x + CGFloat(cos(angle + 1.2)) * side * 0.05,
                                               y: base.y + CGFloat(sin(angle + 1.2)) * side * 0.05))
            leaf.addQuadCurve(to: base,
                              control: CGPoint(x: base.x + CGFloat(cos(angle - 1.2)) * side * 0.05,
                                               y: base.y + CGFloat(sin(angle - 1.2)) * side * 0.05))
            context.fill(leaf, with: .color(TEPalette.moss.opacity(0.28)))
        }

        let dot = Path(ellipseIn: CGRect(x: centre.x - side * 0.012, y: centre.y - side * 0.012,
                                         width: side * 0.024, height: side * 0.024))
        context.fill(dot, with: .color(TEPalette.mossDeep))
    }

    /// Smoothstep, so the shape does not jerk at the turn.
    private func eased(_ t: Double) -> Double {
        let clamped = min(1, max(0, t))
        return clamped * clamped * (3 - 2 * clamped)
    }
}
