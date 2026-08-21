import SwiftUI
import Combine

struct TELadderStep {
    let title: String
    let instruction: String
    let seconds: Int
    let usesMasking: Bool
}

enum TELadder {
    static let steps: [TELadderStep] = [
        TELadderStep(title: "Think about it",
                     instruction: "Bring the sound to mind. Do not play anything and do not seek it out. Just let the idea of it sit there while you breathe out slowly.",
                     seconds: 30,
                     usesMasking: false),
        TELadderStep(title: "Read it",
                     instruction: "Read the description of the trigger on this screen, slowly, twice. Notice what your jaw and shoulders do while you read it.",
                     seconds: 45,
                     usesMasking: false),
        TELadderStep(title: "Hold it with masking on",
                     instruction: "Start the masking sound at a low level. Hold the idea of the sound while it runs. If your distress rises past what you agreed with yourself, stop.",
                     seconds: 60,
                     usesMasking: true),
        TELadderStep(title: "Hold it, longer",
                     instruction: "Same again, with the masking still on. Let the image be a little more detailed — the room, the person, the rhythm of it.",
                     seconds: 90,
                     usesMasking: true),
        TELadderStep(title: "Without masking",
                     instruction: "Turn the masking off. Hold the idea of the sound in a quiet room. This is the step most people find is the real one.",
                     seconds: 60,
                     usesMasking: false),
        TELadderStep(title: "Longer, unmasked",
                     instruction: "The same, for longer. If you get through this comfortably several times, that is as far as this ladder goes — the rest belongs with a therapist if you want to take it further.",
                     seconds: 120,
                     usesMasking: false)
    ]
}

private enum TELadderPhase: Equatable {
    case overview
    case running(Int)
    case rating(Int, Bool)
}

struct TELadderView: View {
    let triggerID: String

    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine
    @Environment(\.presentationMode) private var presentationMode

    @State private var phase: TELadderPhase = .overview
    @State private var remaining = 0
    @State private var distressBefore = 4
    @State private var distressAfter = 4
    @State private var note = ""
    @FocusState private var focused: TEFieldID?

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var trigger: TETrigger? { TETriggerCatalog.byID(triggerID) }

    var body: some View {
        Group {
            switch phase {
            case .overview: overview
            case .running(let index): running(index)
            case .rating(let index, let stopped): rating(index, stoppedEarly: stopped)
            }
        }
        .onReceive(ticker) { _ in tick() }
        .onDisappear { masking.stop() }
    }

    // MARK: - Overview

    private var overview: some View {
        TEPage(title: "Graded ladder",
               subtitle: trigger?.name ?? "",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TECard(background: TEPalette.claySoft.opacity(0.45), border: TEPalette.clay.opacity(0.35)) {
                HStack(spacing: 9) {
                    TEGlyph(kind: .info, size: 17, color: TEPalette.clayDeep)
                    Text("Before you start")
                        .font(TEType.medium(14.5))
                        .foregroundColor(TEPalette.clayDeep)
                    Spacer(minLength: 0)
                }
                Text("Graded exposure means approaching something difficult in small steps rather than all at once. Some people with misophonia report that a gentle, self-paced version helps. Others report that it does not, or that it makes things worse.\n\nIt is generally best done with the support of a therapist, particularly if it is distressing. This ladder is deliberately mild, it records no streaks, and every step can be stopped at any moment with the control on screen. Stopping is a valid outcome and it is recorded as one.")
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.clayDeep.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !store.preferences.ladderOptIn {
                TECard {
                    Text("Turn the ladder on for this device")
                        .font(TEType.medium(15))
                        .foregroundColor(TEPalette.ink)
                    Text("It stays off until you say otherwise, and you can switch it off again in Settings at any time.")
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    TEPrimaryButton(title: "Turn it on", glyph: .check) {
                        store.preferences.ladderOptIn = true
                    }
                }
            } else {
                TESectionHeader(title: "Steps", note: "\(TELadder.steps.count)")
                ForEach(TELadder.steps.indices, id: \.self) { index in
                    stepRow(index)
                }

                let records = store.ladderRecords(for: triggerID)
                if !records.isEmpty {
                    TESectionHeader(title: "What you have done", note: "\(records.count)")
                    TECard {
                        ForEach(records.reversed()) { record in
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text("Step \(record.stepIndex + 1)")
                                        .font(TEType.medium(13.5))
                                        .foregroundColor(TEPalette.ink)
                                    Text(TEFormat.shortDate.string(from: record.date))
                                        .font(TEType.body(11.5))
                                        .foregroundColor(TEPalette.inkFaint)
                                    Spacer(minLength: 0)
                                    if record.stoppedEarly {
                                        Text("stopped")
                                            .font(TEType.body(11))
                                            .foregroundColor(TEPalette.clayDeep)
                                    }
                                }
                                Text("Distress \(record.distressBefore) before, \(record.distressAfter) after.")
                                    .font(TEType.body(12))
                                    .foregroundColor(TEPalette.inkSoft)
                                if !record.note.isEmpty {
                                    Text(record.note)
                                        .font(TEType.body(12))
                                        .foregroundColor(TEPalette.inkFaint)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.vertical, 4)
                            if record.id != records.first?.id { TEQuietRule() }
                        }
                    }
                    TESecondaryButton(title: "Clear this ladder's history", glyph: .trash, tint: TEPalette.rust) {
                        store.clearLadder(for: triggerID)
                    }
                }
            }
        }
    }

    private func stepRow(_ index: Int) -> some View {
        let step = TELadder.steps[index]
        let reached = store.ladderReached(for: triggerID)
        let done = index <= reached
        return TECard(padding: 14) {
            HStack(alignment: .top, spacing: 11) {
                ZStack {
                    Circle().fill(done ? TEPalette.moss : TEPalette.sandDeep.opacity(0.6))
                    if done {
                        TEGlyph(kind: .check, size: 15, color: TEPalette.card, weight: 2.2)
                    } else {
                        Text("\(index + 1)")
                            .font(TEType.mono(13))
                            .foregroundColor(TEPalette.inkSoft)
                    }
                }
                .frame(width: 30, height: 30)
                VStack(alignment: .leading, spacing: 3) {
                    Text(step.title)
                        .font(TEType.medium(15))
                        .foregroundColor(TEPalette.ink)
                    Text(step.instruction)
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(step.seconds) seconds\(step.usesMasking ? " · masking on" : "")")
                        .font(TEType.body(11.5))
                        .foregroundColor(TEPalette.inkFaint)
                }
                Spacer(minLength: 0)
            }
            TESecondaryButton(title: done ? "Do it again" : "Start this step", glyph: .play) {
                start(index)
            }
        }
    }

    // MARK: - Running

    private func running(_ index: Int) -> some View {
        let step = TELadder.steps[index]
        return ZStack(alignment: .top) {
            TEPalette.sand.edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Step \(index + 1) of \(TELadder.steps.count)")
                        .font(TEType.medium(12.5))
                        .tracking(0.8)
                        .foregroundColor(TEPalette.inkFaint)
                    Text(step.title)
                        .font(TEType.display(26))
                        .foregroundColor(TEPalette.ink)

                    HStack {
                        Spacer(minLength: 0)
                        TECountdownRing(remaining: remaining,
                                        total: max(1, step.seconds),
                                        size: TEMetrics.isCompactHeight ? 150 : 180)
                        Spacer(minLength: 0)
                    }

                    TECard {
                        Text(step.instruction)
                            .font(TEType.body(15))
                            .foregroundColor(TEPalette.ink)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                        if index == 1, let trigger = trigger {
                            TEQuietRule()
                            Text(trigger.detail)
                                .font(TEType.body(14))
                                .foregroundColor(TEPalette.inkSoft)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Button(action: { finish(index, stoppedEarly: true) }) {
                        HStack(spacing: 9) {
                            TEGlyph(kind: .stop, size: 17, color: TEPalette.card)
                            Text("Stop now")
                                .font(TEType.title(16))
                                .foregroundColor(TEPalette.card)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(TEPalette.rust)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    TEFootnote(text: "Stopping is recorded as stopping. It does not undo anything and there is nothing to keep up.")
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, TEMetrics.scrollBottomInset)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            TEStatusStrip()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }

    // MARK: - Rating

    private func rating(_ index: Int, stoppedEarly: Bool) -> some View {
        TEPage(title: stoppedEarly ? "You stopped" : "Step finished",
               subtitle: TELadder.steps[index].title) {

            if stoppedEarly {
                TECard(background: TEPalette.claySoft.opacity(0.45), border: TEPalette.clay.opacity(0.35)) {
                    Text("That was the right call.")
                        .font(TEType.medium(15))
                        .foregroundColor(TEPalette.clayDeep)
                    Text("Stopping when a step is too much is the mechanism working, not the mechanism failing. Record it and leave it there.")
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.clayDeep.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            TESectionHeader(title: "Distress before it started")
            TECard {
                TEScalePicker(value: distressBefore, lowLabel: "Calm", highLabel: "Very high") {
                    distressBefore = $0
                }
            }

            TESectionHeader(title: "Distress now")
            TECard {
                TEScalePicker(value: distressAfter, lowLabel: "Calm", highLabel: "Very high") {
                    distressAfter = $0
                }
            }

            TESectionHeader(title: "Note", note: "optional")
            TETextArea(placeholder: "Went up at the start and came back down after about twenty seconds.",
                       text: $note,
                       minHeight: 84,
                       focus: $focused,
                       field: .ladderNote)

            TEPrimaryButton(title: "Save and go back", glyph: .check) {
                focused = nil
                let record = TELadderStepRecord(triggerID: triggerID,
                                                stepIndex: index,
                                                date: Date(),
                                                distressBefore: distressBefore,
                                                distressAfter: distressAfter,
                                                stoppedEarly: stoppedEarly,
                                                note: note)
                store.addLadderRecord(record)
                note = ""
                phase = .overview
            }

            TESecondaryButton(title: "Discard this one", tint: TEPalette.inkSoft) {
                note = ""
                phase = .overview
            }
        }
    }

    // MARK: - Behaviour

    private func start(_ index: Int) {
        let step = TELadder.steps[index]
        remaining = step.seconds
        distressAfter = distressBefore
        if step.usesMasking {
            masking.level = min(0.3, store.preferences.masterLevel)
            let preset = TEMaskPreset(rawValue: store.preferences.defaultMasking) ?? .brown
            masking.play(preset == .none ? .brown : preset, sleepMinutes: nil)
        } else {
            masking.stop()
        }
        phase = .running(index)
    }

    private func tick() {
        guard case .running(let index) = phase else { return }
        if remaining <= 1 {
            finish(index, stoppedEarly: false)
        } else {
            remaining -= 1
        }
    }

    private func finish(_ index: Int, stoppedEarly: Bool) {
        masking.stop()
        remaining = 0
        phase = .rating(index, stoppedEarly)
    }
}

// MARK: - Countdown ring

struct TECountdownRing: View {
    let remaining: Int
    let total: Int
    var size: CGFloat = 180

    var body: some View {
        Canvas { context, _ in
            draw(&context, side: size)
        }
        .frame(width: size, height: size)
    }

    private func draw(_ context: inout GraphicsContext, side: CGFloat) {
        let centre = CGPoint(x: side / 2, y: side / 2)
        let radius = side * 0.40
        let lineWidth = side * 0.055

        var track = Path()
        track.addEllipse(in: CGRect(x: centre.x - radius, y: centre.y - radius,
                                    width: radius * 2, height: radius * 2))
        context.stroke(track, with: .color(TEPalette.sandDeep), style: StrokeStyle(lineWidth: lineWidth))

        let fraction = total > 0 ? min(1, max(0, teSafeDivide(Double(remaining), Double(total)))) : 0
        if fraction > 0 {
            var arc = Path()
            arc.addArc(center: centre, radius: radius,
                       startAngle: .degrees(-90),
                       endAngle: .degrees(-90 + 360 * fraction),
                       clockwise: false)
            context.stroke(arc, with: .color(TEPalette.moss),
                           style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }

        let minutes = remaining / 60
        let seconds = remaining % 60
        let label = minutes > 0 ? String(format: "%d:%02d", minutes, seconds) : "\(seconds)"
        let resolved = context.resolve(Text(label)
            .font(TEType.display(side * 0.24))
            .foregroundColor(TEPalette.ink))
        context.draw(resolved, at: centre, anchor: .center)

        let caption = context.resolve(Text(minutes > 0 ? "remaining" : "seconds left")
            .font(TEType.body(side * 0.062))
            .foregroundColor(TEPalette.inkFaint))
        context.draw(caption, at: CGPoint(x: centre.x, y: centre.y + side * 0.17), anchor: .center)
    }
}
