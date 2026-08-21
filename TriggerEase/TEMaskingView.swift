import SwiftUI

struct TEMaskingView: View {
    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine
    @Environment(\.presentationMode) private var presentationMode

    @State private var pendingPreset: TEMaskPreset?
    @State private var showVolumeWarning = false
    @State private var sleepMinutes: Int = 20

    var body: some View {
        TEPage(title: "Masking",
               subtitle: "A trigger stands out most against silence. This raises the floor slightly so the contrast is smaller.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            if let error = masking.lastError {
                TECard(background: TEPalette.rustSoft, border: TEPalette.rust.opacity(0.4)) {
                    HStack(spacing: 9) {
                        TEGlyph(kind: .warning, size: 17, color: TEPalette.rust)
                        Text(error)
                            .font(TEType.body(13))
                            .foregroundColor(TEPalette.rust)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            nowPlayingCard
            levelCard
            sleepCard

            TESectionHeader(title: "Presets", note: "\(TEMaskPreset.playable.count)")
            ForEach(TEMaskPreset.playable) { preset in
                presetCard(preset)
            }

            TESectionHeader(title: "Using it well")
            TECard {
                bullet("Start it before the trigger begins. Introducing masking partway through works noticeably less well.")
                bullet("Keep it low enough that you stop noticing it within a minute. It is a floor, not a wall.")
                bullet("Continuous, featureless sound beats music — structure attracts attention in its own right.")
                bullet("If you have to raise your voice over your own masking, it is too loud.")
            }

            TECard(background: TEPalette.claySoft.opacity(0.45), border: TEPalette.clay.opacity(0.35)) {
                HStack(spacing: 9) {
                    TEGlyph(kind: .ear, size: 17, color: TEPalette.clayDeep)
                    Text("Protecting your hearing")
                        .font(TEType.medium(14))
                        .foregroundColor(TEPalette.clayDeep)
                    Spacer(minLength: 0)
                }
                Text("Long exposure to continuous sound at high levels through headphones carries a real risk of hearing damage. Set the level while the room is quiet, before the trigger starts — levels chosen mid-episode are usually far too high. An audiologist can advise on safe long-term use.")
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.clayDeep.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear { sleepMinutes = store.preferences.sleepTimerMinutes }
        .alert(isPresented: $showVolumeWarning) {
            Alert(title: Text("Start low"),
                  message: Text("The level starts quiet and ramps in over about a third of a second. Turn it up only until it just covers the trigger — a floor you stop noticing works better than a wall of sound, and it is safer for your hearing."),
                  primaryButton: .default(Text("Understood")) {
                      store.preferences.hasSeenVolumeWarning = true
                      if let preset = pendingPreset {
                          startPreset(preset)
                          pendingPreset = nil
                      }
                  },
                  secondaryButton: .cancel(Text("Not now")) {
                      pendingPreset = nil
                  })
        }
    }

    // MARK: - Cards

    private var nowPlayingCard: some View {
        TECard(background: masking.isPlaying ? TEPalette.mossSoft.opacity(0.5) : TEPalette.card,
               border: masking.isPlaying ? TEPalette.moss.opacity(0.4) : TEPalette.cardEdge) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(masking.isPlaying ? TEPalette.moss : TEPalette.sandDeep.opacity(0.7))
                    TEGlyph(kind: masking.isPlaying ? .wave : .volume,
                            size: 20,
                            color: masking.isPlaying ? TEPalette.card : TEPalette.inkFaint,
                            weight: 1.8)
                }
                .frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: 2) {
                    Text(masking.isPlaying ? masking.activePreset.title : "Nothing playing")
                        .font(TEType.title(16))
                        .foregroundColor(TEPalette.ink)
                    Text(masking.sleepTimerActive
                         ? "Sleep timer: \(timerText)"
                         : (masking.isPlaying ? "No sleep timer set" : "Choose a preset below"))
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkSoft)
                }
                Spacer(minLength: 0)
                if masking.isPlaying {
                    Button(action: { masking.stop() }) {
                        HStack(spacing: 6) {
                            TEGlyph(kind: .stop, size: 14, color: TEPalette.card)
                            Text("Stop")
                                .font(TEType.medium(13))
                                .foregroundColor(TEPalette.card)
                        }
                        .padding(.vertical, 9)
                        .padding(.horizontal, 12)
                        .background(Capsule(style: .continuous).fill(TEPalette.mossDeep))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var timerText: String {
        let total = masking.sleepRemainingSeconds
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var levelCard: some View {
        TECard {
            HStack {
                Text("Level")
                    .font(TEType.medium(14))
                    .foregroundColor(TEPalette.ink)
                Spacer(minLength: 0)
                Text("\(Int((store.preferences.masterLevel * 100).rounded()))%")
                    .font(TEType.mono(13))
                    .foregroundColor(TEPalette.inkSoft)
            }
            TELevelSlider(value: store.preferences.masterLevel) { value in
                store.preferences.masterLevel = value
                masking.level = value
            }
            TEFootnote(text: "One master level, no per-band controls. Set it while the room is quiet.")
        }
    }

    private var sleepCard: some View {
        TECard {
            HStack {
                Text("Sleep timer")
                    .font(TEType.medium(14))
                    .foregroundColor(TEPalette.ink)
                Spacer(minLength: 0)
                if masking.sleepTimerActive {
                    Text(timerText)
                        .font(TEType.mono(13))
                        .foregroundColor(TEPalette.mossDeep)
                }
            }
            TEMinuteStepper(value: sleepMinutes, steps: [0, 15, 20, 30, 60, 120]) { value in
                sleepMinutes = value
                store.preferences.sleepTimerMinutes = value
                if masking.isPlaying {
                    if value > 0 {
                        masking.extendSleepTimer(minutes: value)
                    } else {
                        masking.cancelSleepTimer()
                    }
                }
            }
            TEFootnote(text: "The sound fades out rather than cutting off. Set it to Off to leave it running.")
        }
    }

    private func presetCard(_ preset: TEMaskPreset) -> some View {
        let active = masking.isPlaying && masking.activePreset == preset
        return TECard(padding: 14,
                      background: active ? TEPalette.mossSoft.opacity(0.4) : TEPalette.card,
                      border: active ? TEPalette.moss.opacity(0.4) : TEPalette.cardEdge) {
            HStack(alignment: .top, spacing: 12) {
                TEMaskWaveArt(preset: preset, active: active)
                VStack(alignment: .leading, spacing: 3) {
                    Text(preset.title)
                        .font(TEType.medium(15.5))
                        .foregroundColor(TEPalette.ink)
                    Text(preset.blurb)
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            Button(action: { toggle(preset) }) {
                HStack(spacing: 8) {
                    TEGlyph(kind: active ? .stop : .play, size: 15, color: active ? TEPalette.card : TEPalette.mossDeep)
                    Text(active ? "Stop" : "Play")
                        .font(TEType.medium(14))
                        .foregroundColor(active ? TEPalette.card : TEPalette.mossDeep)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 13)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(active ? TEPalette.mossDeep : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(active ? Color.clear : TEPalette.mossDeep.opacity(0.4), lineWidth: 1.2)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            if store.preferences.defaultMasking == preset.rawValue {
                TEFootnote(text: "Your default preset.")
            } else {
                Button(action: { store.preferences.defaultMasking = preset.rawValue }) {
                    Text("Make this my default")
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkFaint)
                        .padding(.vertical, 3)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Circle()
                .fill(TEPalette.moss)
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(TEType.body(13))
                .foregroundColor(TEPalette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func toggle(_ preset: TEMaskPreset) {
        if masking.isPlaying && masking.activePreset == preset {
            masking.stop()
            return
        }
        if !store.preferences.hasSeenVolumeWarning {
            pendingPreset = preset
            showVolumeWarning = true
            return
        }
        startPreset(preset)
    }

    private func startPreset(_ preset: TEMaskPreset) {
        masking.level = store.preferences.masterLevel
        masking.play(preset, sleepMinutes: sleepMinutes > 0 ? sleepMinutes : nil)
    }
}

// MARK: - Level slider

/// Custom slider. No system controls anywhere in the app.
struct TELevelSlider: View {
    let value: Double
    let onChange: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            let width = max(1, geo.size.width)
            let knobX = CGFloat(min(1, max(0, value))) * width
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(TEPalette.sandDeep)
                    .frame(height: 8)
                Capsule(style: .continuous)
                    .fill(TEPalette.moss)
                    .frame(width: knobX, height: 8)
                Circle()
                    .fill(TEPalette.card)
                    .overlay(Circle().stroke(TEPalette.moss, lineWidth: 2))
                    .frame(width: 24, height: 24)
                    .offset(x: max(0, min(width - 24, knobX - 12)))
            }
            .frame(height: 34)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let fraction = Double(max(0, min(width, gesture.location.x))) / Double(width)
                        onChange(min(1, max(0, fraction)))
                    }
            )
        }
        .frame(height: 34)
    }
}

// MARK: - Preset artwork

/// A small drawn signature per preset, so the six are visually distinguishable.
struct TEMaskWaveArt: View {
    let preset: TEMaskPreset
    let active: Bool
    var size: CGFloat = 44

    var body: some View {
        Canvas { context, _ in
            draw(&context, side: size)
        }
        .frame(width: size, height: size)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(active ? TEPalette.moss.opacity(0.18) : TEPalette.sand)
        )
    }

    private func draw(_ context: inout GraphicsContext, side: CGFloat) {
        let tint = active ? TEPalette.mossDeep : TEPalette.moss
        let midY = side / 2
        var path = Path()
        // String.hashValue is seeded per process, so it would draw a different squiggle on every
        // cold launch. Fold the raw value's scalars instead: one fixed shape per preset, forever.
        var seed: UInt32 = preset.rawValue.unicodeScalars.reduce(UInt32(2_166_136_261)) { accumulated, scalar in
            (accumulated ^ (scalar.value & 0xFF)) &* 16_777_619
        } &+ 7
        func rnd() -> CGFloat {
            seed = 1_664_525 &* seed &+ 1_013_904_223
            return CGFloat(seed >> 16) / CGFloat(1 << 16)
        }

        let steps = 26
        for index in 0...steps {
            let t = CGFloat(index) / CGFloat(steps)
            let x = side * 0.12 + t * side * 0.76
            var amplitude: CGFloat
            switch preset {
            case .white:
                amplitude = (rnd() - 0.5) * side * 0.46
            case .brown:
                amplitude = CGFloat(sin(Double(t) * 6)) * side * 0.16 + (rnd() - 0.5) * side * 0.10
            case .rain:
                amplitude = (rnd() - 0.5) * side * 0.30
            case .fan:
                amplitude = CGFloat(sin(Double(t) * 14)) * side * 0.20
            case .cafe:
                amplitude = CGFloat(sin(Double(t) * 5)) * side * 0.14 + (rnd() - 0.5) * side * 0.16
            case .rumble, .none:
                amplitude = CGFloat(sin(Double(t) * 3)) * side * 0.24
            }
            let point = CGPoint(x: x, y: midY + amplitude)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        context.stroke(path, with: .color(tint),
                       style: StrokeStyle(lineWidth: 1.7, lineCap: .round, lineJoin: .round))
    }
}
