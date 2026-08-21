import SwiftUI

/// Shown for the fraction of a second the launch check takes. Quiet on purpose.
struct TELoadingScreen: View {
    @State private var phase: Double = 0

    var body: some View {
        ZStack {
            TEPalette.sand.edgesIgnoringSafeArea(.all)

            VStack(spacing: 22) {
                Canvas { context, size in
                    draw(&context, size: size)
                }
                .frame(width: 160, height: 160)

                Text("Trigger Ease")
                    .font(TEType.display(24))
                    .foregroundColor(TEPalette.ink)

                Text("A quiet place to plan for the hard ones")
                    .font(TEType.body(13.5))
                    .foregroundColor(TEPalette.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }

    private func draw(_ context: inout GraphicsContext, size: CGSize) {
        let side = min(size.width, size.height)
        guard side > 10 else { return }
        let centre = CGPoint(x: size.width / 2, y: size.height / 2)

        for index in 0..<3 {
            let progress = (phase + Double(index) / 3).truncatingRemainder(dividingBy: 1)
            let radius = side * 0.14 + CGFloat(progress) * side * 0.32
            let opacity = max(0, 1 - progress)
            var ring = Path()
            ring.addEllipse(in: CGRect(x: centre.x - radius, y: centre.y - radius,
                                       width: radius * 2, height: radius * 2))
            context.stroke(ring, with: .color(TEPalette.moss.opacity(opacity * 0.55)),
                           style: StrokeStyle(lineWidth: 1.6))
        }

        var cushion = Path()
        let half = side * 0.15
        cushion.move(to: CGPoint(x: centre.x - half, y: centre.y))
        cushion.addCurve(to: CGPoint(x: centre.x + half, y: centre.y),
                         control1: CGPoint(x: centre.x - half * 0.5, y: centre.y - half * 1.25),
                         control2: CGPoint(x: centre.x + half * 0.5, y: centre.y - half * 1.25))
        cushion.addCurve(to: CGPoint(x: centre.x - half, y: centre.y),
                         control1: CGPoint(x: centre.x + half * 0.5, y: centre.y + half * 1.25),
                         control2: CGPoint(x: centre.x - half * 0.5, y: centre.y + half * 1.25))
        context.fill(cushion, with: .color(TEPalette.mossSoft))
        context.stroke(cushion, with: .color(TEPalette.mossDeep), style: StrokeStyle(lineWidth: 1.8))
    }
}
