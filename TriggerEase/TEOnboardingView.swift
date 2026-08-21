import SwiftUI

struct TEOnboardingPage {
    let title: String
    let body: [String]
    let art: TEOnboardArt.Kind
}

struct TEOnboardingView: View {
    let onFinish: () -> Void

    @State private var index = 0

    private let pages: [TEOnboardingPage] = [
        TEOnboardingPage(
            title: "You are not being oversensitive",
            body: [
                "Trigger Ease is for people who have a strong, involuntary reaction to specific everyday sounds — chewing, sniffing, pen clicking, a bass line through a wall.",
                "The reaction is faster than deliberation. By the time you notice it, the physical part has already happened. Nothing in this app will suggest you could simply decide not to have it.",
                "It also will not tell you what you have. It is a place to prepare, to record, and to find out which of your own strategies actually work."
            ],
            art: .listen),
        TEOnboardingPage(
            title: "Plan the situation before you are in it",
            body: [
                "This is the part that does the most work. Pick a situation — a family meal, an open-plan office, a long car journey — and decide in advance where you will sit, what will be running, which two techniques you will have ready, and the exact sentence you will say if you need to leave.",
                "The plan opens as a single calm page you can read in the moment.",
                "Afterwards you score it: how hard it was, whether you left, and which techniques you actually used."
            ],
            art: .plan),
        TEOnboardingPage(
            title: "The app learns what works for you",
            body: [
                "Across your scored runs, every seating option, masking preset and technique gets a mean rating with its sample count.",
                "Below three samples it says \"still learning\" instead of showing a number it cannot stand behind.",
                "This is your own data about your own situations — not generic advice about what is supposed to help."
            ],
            art: .rank),
        TEOnboardingPage(
            title: "A journal that answers questions",
            body: [
                "Log an episode in about thirty seconds: what the sound was, who was there, how intense it got, what you did, and how long it took to come down.",
                "The analytics then show which triggers and contexts are actually worst, when in the day they cluster, and how your recovery time is moving.",
                "Recovery outlasts the sound by more than most people expect. Recording it separately is what lets the app tell you your own typical figure."
            ],
            art: .journal),
        TEOnboardingPage(
            title: "Your triggers, mapped",
            body: [
                "There are \(TETriggerCatalog.all.count) triggers in the catalogue across six classes, including visual ones — a jiggling leg, a twirling pen — which are real and almost always left out.",
                "Rate the ones you know about and the grid fills in. It is a picture you can show somebody who does not believe you, and it shows what is not a trigger as clearly as what is.",
                "There is also an entirely optional graded ladder, off by default, stoppable at any moment, with no streaks."
            ],
            art: .grid),
        TEOnboardingPage(
            title: "Nothing here will chase you",
            body: [
                "There are no notifications in this app at all. An alert about a trigger is itself an intrusion, and daily prompts encourage exactly the kind of monitoring that tends to make things worse.",
                "No streaks, no scores, no daily goal. Everything you enter stays on this device — no account, no sync, no upload.",
                "Trigger Ease is a self-tracking and preparation tool. It is not a medical device, it does not diagnose anything, and it does not provide medical advice. If this is affecting your sleep, work, study or relationships, speak to a qualified clinician — an audiologist, a psychologist or a physician."
            ],
            art: .quiet)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            TEPalette.sand.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer(minLength: 0)
                            Button(action: onFinish) {
                                Text(index == pages.count - 1 ? "Close" : "Skip")
                                    .font(TEType.medium(14))
                                    .foregroundColor(TEPalette.inkFaint)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 6)

                        TEOnboardArt(kind: page.art,
                                     width: max(120, TEMetrics.screenWidth - 36),
                                     height: TEMetrics.isCompactHeight ? 110 : 150)

                        Text(page.title)
                            .font(TEType.display(TEMetrics.isNarrow ? 24 : 27))
                            .foregroundColor(TEPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)

                        ForEach(page.body.indices, id: \.self) { i in
                            Text(page.body[i])
                                .font(TEType.body(14.5))
                                .foregroundColor(i == 0 ? TEPalette.ink : TEPalette.inkSoft)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                controls
            }
            // No TEStatusStrip here: this screen is presented as a card sheet, whose own top
            // safe-area inset is 0. A strip sized from the key window would paint over the
            // Skip/Close button instead of filling anything.
        }
    }

    private var page: TEOnboardingPage {
        pages[max(0, min(pages.count - 1, index))]
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(pages.indices, id: \.self) { i in
                    Capsule(style: .continuous)
                        .fill(i == index ? TEPalette.moss : TEPalette.sandDeep)
                        .frame(width: i == index ? 20 : 7, height: 7)
                }
            }
            HStack(spacing: 10) {
                if index > 0 {
                    Button(action: { index -= 1 }) {
                        HStack(spacing: 5) {
                            TEGlyph(kind: .chevronLeft, size: 16, color: TEPalette.mossDeep)
                            Text("Back")
                                .font(TEType.medium(15))
                                .foregroundColor(TEPalette.mossDeep)
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(TEPalette.mossDeep.opacity(0.4), lineWidth: 1.2)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                TEPrimaryButton(title: index == pages.count - 1 ? "Understood" : "Next",
                                glyph: index == pages.count - 1 ? .check : nil) {
                    if index == pages.count - 1 {
                        onFinish()
                    } else {
                        index += 1
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(
            TEPalette.card
                .overlay(
                    VStack(spacing: 0) {
                        TEPalette.cardEdge.frame(height: 1)
                        Spacer(minLength: 0)
                    }
                )
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}

/// Line-work illustrations for the introduction. All drawn, no image assets.
struct TEOnboardArt: View {
    enum Kind {
        case listen
        case plan
        case rank
        case journal
        case grid
        case quiet
    }

    let kind: Kind
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { context, _ in
            draw(&context, width: width, height: height)
        }
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TEPalette.card.opacity(0.7))
        )
        .allowsHitTesting(false)
    }

    private func draw(_ context: inout GraphicsContext, width: CGFloat, height: CGFloat) {
        guard width > 20, height > 20 else { return }
        let stroke = StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
        let tint = TEPalette.moss
        let accent = TEPalette.clay
        let centre = CGPoint(x: width / 2, y: height / 2)

        switch kind {
        case .listen:
            var wave = Path()
            let steps = 70
            for i in 0...steps {
                let t = CGFloat(i) / CGFloat(steps)
                let x = width * 0.08 + t * width * 0.46
                let decay = CGFloat(pow(Double(1 - t), 1.4))
                let y = centre.y + CGFloat(sin(Double(t) * 16)) * height * 0.26 * decay
                let point = CGPoint(x: x, y: y)
                if i == 0 { wave.move(to: point) } else { wave.addLine(to: point) }
            }
            context.stroke(wave, with: .color(accent), style: stroke)
            var cushion = Path()
            let left = width * 0.58
            let right = width * 0.90
            cushion.move(to: CGPoint(x: left, y: centre.y))
            cushion.addCurve(to: CGPoint(x: right, y: centre.y),
                             control1: CGPoint(x: left, y: centre.y - height * 0.34),
                             control2: CGPoint(x: right, y: centre.y - height * 0.34))
            cushion.addCurve(to: CGPoint(x: left, y: centre.y),
                             control1: CGPoint(x: right, y: centre.y + height * 0.34),
                             control2: CGPoint(x: left, y: centre.y + height * 0.34))
            context.fill(cushion, with: .color(tint.opacity(0.18)))
            context.stroke(cushion, with: .color(tint), style: stroke)

        case .plan:
            var card = Path()
            card.addRoundedRect(in: CGRect(x: width * 0.20, y: height * 0.16,
                                           width: width * 0.36, height: height * 0.68),
                                cornerSize: CGSize(width: 12, height: 12))
            context.stroke(card, with: .color(tint), style: stroke)
            var lines = Path()
            for i in 0..<4 {
                let y = height * (0.30 + Double(i) * 0.14)
                lines.move(to: CGPoint(x: width * 0.26, y: y))
                lines.addLine(to: CGPoint(x: width * 0.50 - CGFloat(i) * width * 0.02, y: y))
            }
            context.stroke(lines, with: .color(tint.opacity(0.6)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
            var seats = Path()
            for i in 0..<3 {
                let cx = width * (0.66 + Double(i % 2) * 0.14)
                let cy = height * (0.28 + Double(i) * 0.22)
                seats.addEllipse(in: CGRect(x: cx - 9, y: cy - 9, width: 18, height: 18))
            }
            context.stroke(seats, with: .color(accent), style: stroke)

        case .rank:
            let bars: [CGFloat] = [0.75, 0.55, 0.36, 0.22]
            for (i, value) in bars.enumerated() {
                let y = height * (0.22 + Double(i) * 0.18)
                var track = Path()
                track.addRoundedRect(in: CGRect(x: width * 0.14, y: y - 5,
                                                width: width * 0.72, height: 10),
                                     cornerSize: CGSize(width: 5, height: 5))
                context.fill(track, with: .color(TEPalette.sandDeep))
                var fill = Path()
                fill.addRoundedRect(in: CGRect(x: width * 0.14, y: y - 5,
                                               width: width * 0.72 * value, height: 10),
                                    cornerSize: CGSize(width: 5, height: 5))
                context.fill(fill, with: .color(i == 0 ? tint : tint.opacity(0.55)))
            }

        case .journal:
            var book = Path()
            book.addRoundedRect(in: CGRect(x: width * 0.22, y: height * 0.16,
                                           width: width * 0.56, height: height * 0.68),
                                cornerSize: CGSize(width: 12, height: 12))
            context.stroke(book, with: .color(tint), style: stroke)
            var spine = Path()
            spine.move(to: CGPoint(x: width * 0.36, y: height * 0.16))
            spine.addLine(to: CGPoint(x: width * 0.36, y: height * 0.84))
            context.stroke(spine, with: .color(tint.opacity(0.55)), style: stroke)
            var trend = Path()
            trend.move(to: CGPoint(x: width * 0.44, y: height * 0.64))
            trend.addLine(to: CGPoint(x: width * 0.53, y: height * 0.42))
            trend.addLine(to: CGPoint(x: width * 0.62, y: height * 0.54))
            trend.addLine(to: CGPoint(x: width * 0.72, y: height * 0.30))
            context.stroke(trend, with: .color(accent), style: stroke)

        case .grid:
            let cols = 6
            let rows = 3
            let cellW = width * 0.72 / CGFloat(cols)
            let cellH = height * 0.52 / CGFloat(rows)
            var seed: UInt32 = 424242
            for row in 0..<rows {
                for col in 0..<cols {
                    seed = 1_664_525 &* seed &+ 1_013_904_223
                    let value = Int((seed >> 20) % 11)
                    let rect = CGRect(x: width * 0.14 + CGFloat(col) * cellW + 2,
                                      y: height * 0.24 + CGFloat(row) * cellH + 2,
                                      width: cellW - 4, height: cellH - 4)
                    let path = Path(roundedRect: rect, cornerRadius: 4)
                    context.fill(path, with: .color(TEPalette.intensity(value)))
                }
            }

        case .quiet:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: centre.x - height * 0.30, y: centre.y - height * 0.30,
                                       width: height * 0.60, height: height * 0.60))
            context.stroke(ring, with: .color(tint.opacity(0.5)), style: stroke)
            var inner = Path()
            inner.addEllipse(in: CGRect(x: centre.x - height * 0.16, y: centre.y - height * 0.16,
                                        width: height * 0.32, height: height * 0.32))
            context.fill(inner, with: .color(tint.opacity(0.18)))
            context.stroke(inner, with: .color(tint), style: stroke)
            var slash = Path()
            slash.move(to: CGPoint(x: centre.x - height * 0.34, y: centre.y + height * 0.34))
            slash.addLine(to: CGPoint(x: centre.x + height * 0.34, y: centre.y - height * 0.34))
            context.stroke(slash, with: .color(accent), style: stroke)
        }
    }
}
