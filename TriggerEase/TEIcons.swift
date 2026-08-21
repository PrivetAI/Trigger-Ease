import SwiftUI

// Every icon in Trigger Ease is drawn here in Canvas. No SF Symbols, no emoji, no image assets.

enum TEGlyphKind {
    case plan
    case journal
    case triggers
    case toolkit
    case settings
    case ease
    case ear
    case wave
    case leaf
    case plus
    case close
    case check
    case chevronRight
    case chevronLeft
    case chevronDown
    case search
    case filter
    case star
    case starFilled
    case lock
    case trash
    case edit
    case play
    case stop
    case clock
    case person
    case place
    case speech
    case ladder
    case grid
    case chart
    case info
    case shield
    case exit
    case seat
    case repeatArrow
    case volume
    case timer
    case book
    case warning
}

struct TEGlyph: View {
    let kind: TEGlyphKind
    var size: CGFloat = 22
    var color: Color = TEPalette.ink
    var weight: CGFloat = 1.7

    var body: some View {
        Canvas { context, _ in
            TEGlyph.draw(kind: kind, in: &context, side: size, color: color, weight: weight)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    // MARK: - Drawing

    static func draw(kind: TEGlyphKind, in context: inout GraphicsContext, side: CGFloat, color: Color, weight: CGFloat) {
        let s = side
        let stroke = StrokeStyle(lineWidth: weight, lineCap: .round, lineJoin: .round)
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

        switch kind {
        case .plan:
            var body = Path()
            body.addRoundedRect(in: CGRect(x: 0.17 * s, y: 0.16 * s, width: 0.66 * s, height: 0.70 * s),
                                cornerSize: CGSize(width: 0.12 * s, height: 0.12 * s))
            context.stroke(body, with: .color(color), style: stroke)
            var lines = Path()
            lines.move(to: p(0.30, 0.40)); lines.addLine(to: p(0.70, 0.40))
            lines.move(to: p(0.30, 0.54)); lines.addLine(to: p(0.62, 0.54))
            lines.move(to: p(0.30, 0.68)); lines.addLine(to: p(0.55, 0.68))
            context.stroke(lines, with: .color(color), style: stroke)
            var tab = Path()
            tab.move(to: p(0.36, 0.16)); tab.addLine(to: p(0.36, 0.08))
            tab.move(to: p(0.64, 0.16)); tab.addLine(to: p(0.64, 0.08))
            context.stroke(tab, with: .color(color), style: stroke)

        case .journal:
            var cover = Path()
            cover.addRoundedRect(in: CGRect(x: 0.22 * s, y: 0.13 * s, width: 0.60 * s, height: 0.74 * s),
                                 cornerSize: CGSize(width: 0.09 * s, height: 0.09 * s))
            context.stroke(cover, with: .color(color), style: stroke)
            var spine = Path()
            spine.move(to: p(0.36, 0.13)); spine.addLine(to: p(0.36, 0.87))
            context.stroke(spine, with: .color(color.opacity(0.6)), style: stroke)
            var marks = Path()
            marks.move(to: p(0.46, 0.34)); marks.addLine(to: p(0.72, 0.34))
            marks.move(to: p(0.46, 0.50)); marks.addLine(to: p(0.72, 0.50))
            marks.move(to: p(0.46, 0.66)); marks.addLine(to: p(0.63, 0.66))
            context.stroke(marks, with: .color(color), style: stroke)

        case .triggers:
            var outer = Path()
            outer.addArc(center: p(0.5, 0.5), radius: 0.36 * s, startAngle: .degrees(-40), endAngle: .degrees(220), clockwise: false)
            context.stroke(outer, with: .color(color.opacity(0.5)), style: stroke)
            var mid = Path()
            mid.addArc(center: p(0.5, 0.5), radius: 0.22 * s, startAngle: .degrees(-40), endAngle: .degrees(220), clockwise: false)
            context.stroke(mid, with: .color(color.opacity(0.75)), style: stroke)
            let dot = Path(ellipseIn: CGRect(x: 0.42 * s, y: 0.42 * s, width: 0.16 * s, height: 0.16 * s))
            context.fill(dot, with: .color(color))

        case .toolkit:
            var box = Path()
            box.addRoundedRect(in: CGRect(x: 0.14 * s, y: 0.34 * s, width: 0.72 * s, height: 0.50 * s),
                               cornerSize: CGSize(width: 0.10 * s, height: 0.10 * s))
            context.stroke(box, with: .color(color), style: stroke)
            var handle = Path()
            handle.move(to: p(0.36, 0.34))
            handle.addLine(to: p(0.36, 0.22))
            handle.addLine(to: p(0.64, 0.22))
            handle.addLine(to: p(0.64, 0.34))
            context.stroke(handle, with: .color(color), style: stroke)
            var latch = Path()
            latch.move(to: p(0.14, 0.55)); latch.addLine(to: p(0.86, 0.55))
            context.stroke(latch, with: .color(color.opacity(0.65)), style: stroke)

        case .settings:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: 0.20 * s, y: 0.20 * s, width: 0.60 * s, height: 0.60 * s))
            context.stroke(ring, with: .color(color), style: stroke)
            var spokes = Path()
            for i in 0..<6 {
                let a = CGFloat(i) * .pi / 3
                let inner = CGPoint(x: 0.5 * s + cos(a) * 0.30 * s, y: 0.5 * s + sin(a) * 0.30 * s)
                let outer = CGPoint(x: 0.5 * s + cos(a) * 0.42 * s, y: 0.5 * s + sin(a) * 0.42 * s)
                spokes.move(to: inner); spokes.addLine(to: outer)
            }
            context.stroke(spokes, with: .color(color), style: stroke)
            let core = Path(ellipseIn: CGRect(x: 0.41 * s, y: 0.41 * s, width: 0.18 * s, height: 0.18 * s))
            context.fill(core, with: .color(color))

        case .ease:
            var petal = Path()
            petal.move(to: p(0.50, 0.14))
            petal.addCurve(to: p(0.50, 0.86), control1: p(0.90, 0.34), control2: p(0.90, 0.66))
            petal.addCurve(to: p(0.50, 0.14), control1: p(0.10, 0.66), control2: p(0.10, 0.34))
            context.fill(petal, with: .color(color.opacity(0.22)))
            context.stroke(petal, with: .color(color), style: stroke)
            var vein = Path()
            vein.move(to: p(0.50, 0.20)); vein.addLine(to: p(0.50, 0.80))
            context.stroke(vein, with: .color(color.opacity(0.7)), style: stroke)

        case .ear:
            var outer = Path()
            outer.move(to: p(0.62, 0.86))
            outer.addCurve(to: p(0.62, 0.52), control1: p(0.50, 0.80), control2: p(0.66, 0.66))
            outer.addCurve(to: p(0.34, 0.40), control1: p(0.58, 0.38), control2: p(0.36, 0.44))
            outer.addCurve(to: p(0.72, 0.24), control1: p(0.30, 0.16), control2: p(0.72, 0.10))
            context.stroke(outer, with: .color(color), style: stroke)
            var inner = Path()
            inner.addArc(center: p(0.50, 0.42), radius: 0.10 * s, startAngle: .degrees(60), endAngle: .degrees(320), clockwise: false)
            context.stroke(inner, with: .color(color.opacity(0.7)), style: stroke)

        case .wave:
            var path = Path()
            let mid: CGFloat = 0.5
            path.move(to: p(0.10, mid))
            var x: CGFloat = 0.10
            var flip = true
            while x < 0.88 {
                let next = x + 0.13
                path.addQuadCurve(to: p(min(next, 0.90), mid),
                                  control: p(x + 0.065, flip ? mid - 0.26 : mid + 0.26))
                x = next
                flip.toggle()
            }
            context.stroke(path, with: .color(color), style: stroke)

        case .leaf:
            var leaf = Path()
            leaf.move(to: p(0.18, 0.82))
            leaf.addCurve(to: p(0.82, 0.18), control1: p(0.18, 0.34), control2: p(0.44, 0.18))
            leaf.addCurve(to: p(0.18, 0.82), control1: p(0.82, 0.62), control2: p(0.62, 0.82))
            context.fill(leaf, with: .color(color.opacity(0.20)))
            context.stroke(leaf, with: .color(color), style: stroke)
            var stem = Path()
            stem.move(to: p(0.18, 0.82)); stem.addLine(to: p(0.68, 0.34))
            context.stroke(stem, with: .color(color.opacity(0.8)), style: stroke)

        case .plus:
            var path = Path()
            path.move(to: p(0.5, 0.20)); path.addLine(to: p(0.5, 0.80))
            path.move(to: p(0.20, 0.5)); path.addLine(to: p(0.80, 0.5))
            context.stroke(path, with: .color(color), style: stroke)

        case .close:
            var path = Path()
            path.move(to: p(0.26, 0.26)); path.addLine(to: p(0.74, 0.74))
            path.move(to: p(0.74, 0.26)); path.addLine(to: p(0.26, 0.74))
            context.stroke(path, with: .color(color), style: stroke)

        case .check:
            var path = Path()
            path.move(to: p(0.22, 0.52)); path.addLine(to: p(0.42, 0.72)); path.addLine(to: p(0.78, 0.28))
            context.stroke(path, with: .color(color), style: stroke)

        case .chevronRight:
            var path = Path()
            path.move(to: p(0.38, 0.24)); path.addLine(to: p(0.64, 0.5)); path.addLine(to: p(0.38, 0.76))
            context.stroke(path, with: .color(color), style: stroke)

        case .chevronLeft:
            var path = Path()
            path.move(to: p(0.62, 0.24)); path.addLine(to: p(0.36, 0.5)); path.addLine(to: p(0.62, 0.76))
            context.stroke(path, with: .color(color), style: stroke)

        case .chevronDown:
            var path = Path()
            path.move(to: p(0.24, 0.40)); path.addLine(to: p(0.5, 0.64)); path.addLine(to: p(0.76, 0.40))
            context.stroke(path, with: .color(color), style: stroke)

        case .search:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: 0.18 * s, y: 0.18 * s, width: 0.46 * s, height: 0.46 * s))
            context.stroke(ring, with: .color(color), style: stroke)
            var tail = Path()
            tail.move(to: p(0.60, 0.60)); tail.addLine(to: p(0.82, 0.82))
            context.stroke(tail, with: .color(color), style: stroke)

        case .filter:
            var path = Path()
            path.move(to: p(0.16, 0.26)); path.addLine(to: p(0.84, 0.26))
            path.addLine(to: p(0.58, 0.52)); path.addLine(to: p(0.58, 0.80))
            path.addLine(to: p(0.42, 0.70)); path.addLine(to: p(0.42, 0.52))
            path.closeSubpath()
            context.stroke(path, with: .color(color), style: stroke)

        case .star, .starFilled:
            var path = Path()
            let cx: CGFloat = 0.5, cy: CGFloat = 0.52
            for i in 0..<10 {
                let radius: CGFloat = (i % 2 == 0) ? 0.36 : 0.155
                let angle = -CGFloat.pi / 2 + CGFloat(i) * .pi / 5
                let point = CGPoint(x: (cx + cos(angle) * radius) * s, y: (cy + sin(angle) * radius) * s)
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            path.closeSubpath()
            if kind == .starFilled { context.fill(path, with: .color(color)) }
            context.stroke(path, with: .color(color), style: stroke)

        case .lock:
            var body = Path()
            body.addRoundedRect(in: CGRect(x: 0.24 * s, y: 0.44 * s, width: 0.52 * s, height: 0.40 * s),
                                cornerSize: CGSize(width: 0.10 * s, height: 0.10 * s))
            context.stroke(body, with: .color(color), style: stroke)
            var shackle = Path()
            shackle.addArc(center: p(0.5, 0.44), radius: 0.17 * s, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            context.stroke(shackle, with: .color(color), style: stroke)
            let keyhole = Path(ellipseIn: CGRect(x: 0.455 * s, y: 0.58 * s, width: 0.09 * s, height: 0.09 * s))
            context.fill(keyhole, with: .color(color))

        case .trash:
            var body = Path()
            body.move(to: p(0.26, 0.30))
            body.addLine(to: p(0.32, 0.84))
            body.addLine(to: p(0.68, 0.84))
            body.addLine(to: p(0.74, 0.30))
            context.stroke(body, with: .color(color), style: stroke)
            var lid = Path()
            lid.move(to: p(0.18, 0.30)); lid.addLine(to: p(0.82, 0.30))
            lid.move(to: p(0.40, 0.30)); lid.addLine(to: p(0.42, 0.18)); lid.addLine(to: p(0.58, 0.18)); lid.addLine(to: p(0.60, 0.30))
            context.stroke(lid, with: .color(color), style: stroke)

        case .edit:
            var pen = Path()
            pen.move(to: p(0.24, 0.76))
            pen.addLine(to: p(0.66, 0.20))
            pen.addLine(to: p(0.80, 0.31))
            pen.addLine(to: p(0.38, 0.86))
            pen.closeSubpath()
            context.stroke(pen, with: .color(color), style: stroke)
            var nib = Path()
            nib.move(to: p(0.24, 0.76)); nib.addLine(to: p(0.38, 0.86))
            context.stroke(nib, with: .color(color), style: stroke)

        case .play:
            var path = Path()
            path.move(to: p(0.34, 0.22)); path.addLine(to: p(0.78, 0.5)); path.addLine(to: p(0.34, 0.78))
            path.closeSubpath()
            context.fill(path, with: .color(color))

        case .stop:
            var path = Path()
            path.addRoundedRect(in: CGRect(x: 0.30 * s, y: 0.30 * s, width: 0.40 * s, height: 0.40 * s),
                                cornerSize: CGSize(width: 0.08 * s, height: 0.08 * s))
            context.fill(path, with: .color(color))

        case .clock:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: 0.16 * s, y: 0.16 * s, width: 0.68 * s, height: 0.68 * s))
            context.stroke(ring, with: .color(color), style: stroke)
            var hands = Path()
            hands.move(to: p(0.5, 0.30)); hands.addLine(to: p(0.5, 0.52)); hands.addLine(to: p(0.66, 0.60))
            context.stroke(hands, with: .color(color), style: stroke)

        case .person:
            var head = Path()
            head.addEllipse(in: CGRect(x: 0.36 * s, y: 0.16 * s, width: 0.28 * s, height: 0.28 * s))
            context.stroke(head, with: .color(color), style: stroke)
            var shoulders = Path()
            shoulders.move(to: p(0.20, 0.84))
            shoulders.addQuadCurve(to: p(0.80, 0.84), control: p(0.50, 0.46))
            context.stroke(shoulders, with: .color(color), style: stroke)

        case .place:
            var pin = Path()
            pin.move(to: p(0.5, 0.88))
            pin.addCurve(to: p(0.5, 0.12), control1: p(0.12, 0.56), control2: p(0.14, 0.12))
            pin.addCurve(to: p(0.5, 0.88), control1: p(0.86, 0.12), control2: p(0.88, 0.56))
            context.stroke(pin, with: .color(color), style: stroke)
            var dot = Path()
            dot.addEllipse(in: CGRect(x: 0.40 * s, y: 0.28 * s, width: 0.20 * s, height: 0.20 * s))
            context.stroke(dot, with: .color(color), style: stroke)

        case .speech:
            var bubble = Path()
            bubble.addRoundedRect(in: CGRect(x: 0.13 * s, y: 0.20 * s, width: 0.74 * s, height: 0.50 * s),
                                  cornerSize: CGSize(width: 0.14 * s, height: 0.14 * s))
            context.stroke(bubble, with: .color(color), style: stroke)
            var tail = Path()
            tail.move(to: p(0.32, 0.70)); tail.addLine(to: p(0.28, 0.86)); tail.addLine(to: p(0.48, 0.70))
            context.stroke(tail, with: .color(color), style: stroke)

        case .ladder:
            var rails = Path()
            rails.move(to: p(0.30, 0.12)); rails.addLine(to: p(0.30, 0.88))
            rails.move(to: p(0.70, 0.12)); rails.addLine(to: p(0.70, 0.88))
            context.stroke(rails, with: .color(color), style: stroke)
            var rungs = Path()
            for i in 0..<4 {
                let y = 0.26 + CGFloat(i) * 0.16
                rungs.move(to: p(0.30, y)); rungs.addLine(to: p(0.70, y))
            }
            context.stroke(rungs, with: .color(color), style: stroke)

        case .grid:
            var path = Path()
            for row in 0..<3 {
                for col in 0..<3 {
                    let x = 0.16 + CGFloat(col) * 0.25
                    let y = 0.16 + CGFloat(row) * 0.25
                    path.addRoundedRect(in: CGRect(x: x * s, y: y * s, width: 0.18 * s, height: 0.18 * s),
                                        cornerSize: CGSize(width: 0.04 * s, height: 0.04 * s))
                }
            }
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: weight * 0.8, lineCap: .round))

        case .chart:
            var axis = Path()
            axis.move(to: p(0.16, 0.16)); axis.addLine(to: p(0.16, 0.84)); axis.addLine(to: p(0.86, 0.84))
            context.stroke(axis, with: .color(color.opacity(0.55)), style: stroke)
            var line = Path()
            line.move(to: p(0.24, 0.66))
            line.addLine(to: p(0.42, 0.42))
            line.addLine(to: p(0.58, 0.56))
            line.addLine(to: p(0.80, 0.26))
            context.stroke(line, with: .color(color), style: stroke)

        case .info:
            var ring = Path()
            ring.addEllipse(in: CGRect(x: 0.16 * s, y: 0.16 * s, width: 0.68 * s, height: 0.68 * s))
            context.stroke(ring, with: .color(color), style: stroke)
            var stem = Path()
            stem.move(to: p(0.5, 0.46)); stem.addLine(to: p(0.5, 0.68))
            context.stroke(stem, with: .color(color), style: stroke)
            let dot = Path(ellipseIn: CGRect(x: 0.455 * s, y: 0.30 * s, width: 0.09 * s, height: 0.09 * s))
            context.fill(dot, with: .color(color))

        case .shield:
            var path = Path()
            path.move(to: p(0.5, 0.12))
            path.addLine(to: p(0.84, 0.26))
            path.addCurve(to: p(0.5, 0.88), control1: p(0.84, 0.62), control2: p(0.68, 0.80))
            path.addCurve(to: p(0.16, 0.26), control1: p(0.32, 0.80), control2: p(0.16, 0.62))
            path.closeSubpath()
            context.stroke(path, with: .color(color), style: stroke)

        case .exit:
            var frame = Path()
            frame.move(to: p(0.56, 0.16)); frame.addLine(to: p(0.24, 0.16))
            frame.addLine(to: p(0.24, 0.84)); frame.addLine(to: p(0.56, 0.84))
            context.stroke(frame, with: .color(color), style: stroke)
            var arrow = Path()
            arrow.move(to: p(0.46, 0.50)); arrow.addLine(to: p(0.84, 0.50))
            arrow.move(to: p(0.70, 0.36)); arrow.addLine(to: p(0.84, 0.50)); arrow.addLine(to: p(0.70, 0.64))
            context.stroke(arrow, with: .color(color), style: stroke)

        case .seat:
            var back = Path()
            back.addRoundedRect(in: CGRect(x: 0.28 * s, y: 0.16 * s, width: 0.44 * s, height: 0.38 * s),
                                cornerSize: CGSize(width: 0.10 * s, height: 0.10 * s))
            context.stroke(back, with: .color(color), style: stroke)
            var seat = Path()
            seat.addRoundedRect(in: CGRect(x: 0.20 * s, y: 0.54 * s, width: 0.60 * s, height: 0.16 * s),
                                cornerSize: CGSize(width: 0.07 * s, height: 0.07 * s))
            context.stroke(seat, with: .color(color), style: stroke)
            var legs = Path()
            legs.move(to: p(0.28, 0.70)); legs.addLine(to: p(0.28, 0.86))
            legs.move(to: p(0.72, 0.70)); legs.addLine(to: p(0.72, 0.86))
            context.stroke(legs, with: .color(color), style: stroke)

        case .repeatArrow:
            var arc = Path()
            arc.addArc(center: p(0.5, 0.5), radius: 0.30 * s, startAngle: .degrees(120), endAngle: .degrees(50), clockwise: false)
            context.stroke(arc, with: .color(color), style: stroke)
            var head = Path()
            head.move(to: p(0.60, 0.16)); head.addLine(to: p(0.72, 0.28)); head.addLine(to: p(0.56, 0.34))
            context.stroke(head, with: .color(color), style: stroke)

        case .volume:
            var body = Path()
            body.move(to: p(0.16, 0.38))
            body.addLine(to: p(0.30, 0.38))
            body.addLine(to: p(0.48, 0.20))
            body.addLine(to: p(0.48, 0.80))
            body.addLine(to: p(0.30, 0.62))
            body.addLine(to: p(0.16, 0.62))
            body.closeSubpath()
            context.stroke(body, with: .color(color), style: stroke)
            var waves = Path()
            waves.addArc(center: p(0.50, 0.50), radius: 0.18 * s, startAngle: .degrees(-55), endAngle: .degrees(55), clockwise: false)
            waves.addArc(center: p(0.50, 0.50), radius: 0.30 * s, startAngle: .degrees(-55), endAngle: .degrees(55), clockwise: false)
            context.stroke(waves, with: .color(color.opacity(0.8)), style: stroke)

        case .timer:
            var ring = Path()
            ring.addArc(center: p(0.5, 0.56), radius: 0.32 * s, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            context.stroke(ring, with: .color(color), style: stroke)
            var top = Path()
            top.move(to: p(0.40, 0.12)); top.addLine(to: p(0.60, 0.12))
            top.move(to: p(0.5, 0.12)); top.addLine(to: p(0.5, 0.24))
            context.stroke(top, with: .color(color), style: stroke)
            var hand = Path()
            hand.move(to: p(0.5, 0.56)); hand.addLine(to: p(0.66, 0.42))
            context.stroke(hand, with: .color(color), style: stroke)

        case .book:
            var path = Path()
            path.move(to: p(0.5, 0.24))
            path.addCurve(to: p(0.14, 0.20), control1: p(0.36, 0.14), control2: p(0.22, 0.16))
            path.addLine(to: p(0.14, 0.78))
            path.addCurve(to: p(0.5, 0.82), control1: p(0.22, 0.74), control2: p(0.36, 0.72))
            path.addCurve(to: p(0.86, 0.78), control1: p(0.64, 0.72), control2: p(0.78, 0.74))
            path.addLine(to: p(0.86, 0.20))
            path.addCurve(to: p(0.5, 0.24), control1: p(0.78, 0.16), control2: p(0.64, 0.14))
            context.stroke(path, with: .color(color), style: stroke)
            var spine = Path()
            spine.move(to: p(0.5, 0.24)); spine.addLine(to: p(0.5, 0.82))
            context.stroke(spine, with: .color(color.opacity(0.7)), style: stroke)

        case .warning:
            var tri = Path()
            tri.move(to: p(0.5, 0.14))
            tri.addLine(to: p(0.88, 0.82))
            tri.addLine(to: p(0.12, 0.82))
            tri.closeSubpath()
            context.stroke(tri, with: .color(color), style: stroke)
            var bang = Path()
            bang.move(to: p(0.5, 0.40)); bang.addLine(to: p(0.5, 0.60))
            context.stroke(bang, with: .color(color), style: stroke)
            let dot = Path(ellipseIn: CGRect(x: 0.46 * s, y: 0.66 * s, width: 0.08 * s, height: 0.08 * s))
            context.fill(dot, with: .color(color))
        }
    }
}

/// Quiet decorative line-work used at the top of section headers.
struct TEQuietRule: View {
    var color: Color = TEPalette.line
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 1))
        }
        .frame(height: 1)
    }
}
