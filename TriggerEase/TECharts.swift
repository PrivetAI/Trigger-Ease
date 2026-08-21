import SwiftUI

// Every chart in the app is drawn here in Canvas. The Canvas closure's own `size` is never
// trusted for layout maths — the caller passes the geometry in.

// MARK: - Horizontal bar row

struct TEBarRow: View {
    let label: String
    let value: Double
    let maxValue: Double
    let caption: String
    var tint: Color = TEPalette.moss
    var showsValue: Bool = true
    var valueText: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(label)
                    .font(TEType.medium(13.5))
                    .foregroundColor(TEPalette.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 6)
                if showsValue {
                    Text(valueText ?? TEFormat.decimal(value))
                        .font(TEType.mono(13))
                        .foregroundColor(TEPalette.ink)
                }
            }
            GeometryReader { geo in
                let width = max(1, geo.size.width)
                let fraction = maxValue > 0 ? min(1, max(0, teSafeDivide(value, maxValue))) : 0
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(TEPalette.sandDeep)
                        .frame(height: 9)
                    Capsule(style: .continuous)
                        .fill(tint)
                        .frame(width: max(fraction > 0 ? 6 : 0, width * CGFloat(fraction)), height: 9)
                }
                .frame(height: 9)
            }
            .frame(height: 9)
            Text(caption)
                .font(TEType.body(11))
                .foregroundColor(TEPalette.inkFaint)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Vertical bar chart

struct TEBarChart: View {
    let values: [Double]
    let labels: [String]
    let counts: [Int]
    let maxValue: Double
    var height: CGFloat = 130
    var tint: Color = TEPalette.moss
    /// When true a bar's colour is taken from the intensity ramp instead of the flat tint.
    var intensityTinted: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Canvas { context, size in
                draw(&context, size: size)
            }
            .frame(height: height)

            HStack(spacing: 0) {
                ForEach(labels.indices, id: \.self) { index in
                    Text(labels[index])
                        .font(TEType.body(9.5))
                        .foregroundColor(TEPalette.inkFaint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func draw(_ context: inout GraphicsContext, size: CGSize) {
        guard !values.isEmpty, size.width > 0, size.height > 0 else { return }
        let count = values.count
        let slot = teSafeDivide(Double(size.width), Double(count))
        guard slot > 0 else { return }
        let barWidth = CGFloat(max(4, min(slot * 0.62, 34)))
        let top: CGFloat = 8
        let usable = max(1, size.height - top - 2)
        let scale = maxValue > 0 ? maxValue : 1

        // Baseline
        var base = Path()
        base.move(to: CGPoint(x: 0, y: size.height - 1))
        base.addLine(to: CGPoint(x: size.width, y: size.height - 1))
        context.stroke(base, with: .color(TEPalette.line), style: StrokeStyle(lineWidth: 1))

        for index in 0..<count {
            let value = max(0, values[index])
            let fraction = min(1, teSafeDivide(value, scale))
            let barHeight = max(value > 0 ? 3 : 0, usable * CGFloat(fraction))
            let centreX = CGFloat(slot * (Double(index) + 0.5))
            let rect = CGRect(x: centreX - barWidth / 2,
                              y: size.height - 1 - barHeight,
                              width: barWidth,
                              height: barHeight)
            let path = Path(roundedRect: rect, cornerRadius: min(5, barWidth / 2))
            let colour: Color
            if intensityTinted {
                colour = TEPalette.intensity(Int(value.rounded()))
            } else if index < counts.count && counts[index] == 0 {
                colour = TEPalette.sandDeep
            } else {
                colour = tint
            }
            context.fill(path, with: .color(colour))
        }
    }
}

// MARK: - Line chart

struct TELineChart: View {
    let points: [Double]
    let counts: [Int]
    let maxValue: Double
    var height: CGFloat = 140
    var tint: Color = TEPalette.moss
    var fillUnder: Bool = true

    var body: some View {
        Canvas { context, size in
            draw(&context, size: size)
        }
        .frame(height: height)
    }

    private func draw(_ context: inout GraphicsContext, size: CGSize) {
        guard points.count >= 2, size.width > 2, size.height > 2 else { return }
        let inset: CGFloat = 6
        let usableHeight = max(1, size.height - inset * 2)
        let step = teSafeDivide(Double(size.width - inset * 2), Double(points.count - 1))
        let scale = maxValue > 0 ? maxValue : 1

        // Gridlines at quarters
        var grid = Path()
        for i in 1..<4 {
            let y = inset + usableHeight * CGFloat(i) / 4
            grid.move(to: CGPoint(x: 0, y: y))
            grid.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.stroke(grid, with: .color(TEPalette.line.opacity(0.7)), style: StrokeStyle(lineWidth: 0.7))

        func position(_ index: Int) -> CGPoint {
            let value = min(scale, max(0, points[index]))
            let fraction = teSafeDivide(value, scale)
            let x = inset + CGFloat(step * Double(index))
            let y = inset + usableHeight * CGFloat(1 - fraction)
            return CGPoint(x: x, y: y)
        }

        var line = Path()
        line.move(to: position(0))
        for index in 1..<points.count {
            line.addLine(to: position(index))
        }

        if fillUnder {
            var area = line
            area.addLine(to: CGPoint(x: position(points.count - 1).x, y: size.height - inset))
            area.addLine(to: CGPoint(x: position(0).x, y: size.height - inset))
            area.closeSubpath()
            context.fill(area, with: .color(tint.opacity(0.16)))
        }

        context.stroke(line, with: .color(tint), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

        for index in 0..<points.count {
            let hasData = index < counts.count ? counts[index] > 0 : true
            guard hasData else { continue }
            let p = position(index)
            let dot = Path(ellipseIn: CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6))
            context.fill(dot, with: .color(tint))
        }
    }
}

// MARK: - Heat grid

struct TEHeatCell: Identifiable, Hashable {
    var id: String { key }
    let key: String
    let label: String
    let value: Int?
}

/// The picture a user can show somebody else to explain themselves.
struct TEHeatGrid: View {
    let cells: [TEHeatCell]
    let columns: Int
    /// Width available to the grid, passed in by the caller after subtracting EVERY inset.
    let availableWidth: CGFloat
    var cellHeight: CGFloat = 40
    var onTap: ((TEHeatCell) -> Void)? = nil

    var body: some View {
        let cols = max(1, columns)
        let spacing: CGFloat = 5
        let totalSpacing = spacing * CGFloat(cols - 1)
        let cellWidth = max(18, (availableWidth - totalSpacing) / CGFloat(cols))

        VStack(alignment: .leading, spacing: spacing) {
            ForEach(rowIndices(cols), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(Array(0..<cols), id: \.self) { column in
                        let index = row * cols + column
                        if index < cells.count {
                            cellView(cells[index], width: cellWidth)
                        } else {
                            Color.clear.frame(width: cellWidth, height: cellHeight)
                        }
                    }
                }
            }
        }
    }

    private func rowIndices(_ cols: Int) -> [Int] {
        guard cols > 0, !cells.isEmpty else { return [] }
        let rows = Int(ceil(Double(cells.count) / Double(cols)))
        return Array(0..<max(0, rows))
    }

    private func cellView(_ cell: TEHeatCell, width: CGFloat) -> some View {
        Button(action: { onTap?(cell) }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(cell.value == nil ? TEPalette.sandDeep.opacity(0.5) : TEPalette.intensity(cell.value ?? 0))
                Text(cell.value.map { "\($0)" } ?? "–")
                    .font(TEType.mono(12))
                    .foregroundColor(cell.value == nil ? TEPalette.inkFaint : TEPalette.intensityInk(cell.value ?? 0))
            }
            .frame(width: width, height: cellHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
}

struct TEHeatLegend: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("0")
                .font(TEType.body(10))
                .foregroundColor(TEPalette.inkFaint)
            HStack(spacing: 2) {
                ForEach(0...10, id: \.self) { value in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(TEPalette.intensity(value))
                        .frame(height: 10)
                }
            }
            Text("10")
                .font(TEType.body(10))
                .foregroundColor(TEPalette.inkFaint)
        }
    }
}

// MARK: - Dial

/// A quiet ring used for single figures such as mean intensity.
struct TEDial: View {
    let value: Double
    let maxValue: Double
    let caption: String
    var size: CGFloat = 86
    var tint: Color = TEPalette.moss

    var body: some View {
        VStack(spacing: 6) {
            Canvas { context, _ in
                draw(&context, side: size)
            }
            .frame(width: size, height: size)
            Text(caption)
                .font(TEType.body(11))
                .foregroundColor(TEPalette.inkFaint)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func draw(_ context: inout GraphicsContext, side: CGFloat) {
        let centre = CGPoint(x: side / 2, y: side / 2)
        let radius = side * 0.40
        let lineWidth = side * 0.10

        var track = Path()
        track.addArc(center: centre, radius: radius, startAngle: .degrees(135), endAngle: .degrees(45), clockwise: false)
        context.stroke(track, with: .color(TEPalette.sandDeep),
                       style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

        let fraction = maxValue > 0 ? min(1, max(0, teSafeDivide(value, maxValue))) : 0
        if fraction > 0 {
            let sweep = 270.0 * fraction
            var arc = Path()
            arc.addArc(center: centre, radius: radius,
                       startAngle: .degrees(135), endAngle: .degrees(135 + sweep), clockwise: false)
            context.stroke(arc, with: .color(tint),
                           style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }

        let text = value.isFinite ? TEFormat.decimal(value) : "—"
        let resolved = context.resolve(Text(text)
            .font(TEType.display(side * 0.28))
            .foregroundColor(TEPalette.ink))
        context.draw(resolved, at: centre, anchor: .center)
    }
}

// MARK: - Clock face distribution

/// Twenty-four-hour distribution drawn as a radial plot — compact, and it reads as a day.
struct TEDayClock: View {
    let slices: [TEAnalytics.HourSlice]
    var size: CGFloat = 170

    var body: some View {
        Canvas { context, _ in
            draw(&context, side: size)
        }
        .frame(width: size, height: size)
    }

    private func draw(_ context: inout GraphicsContext, side: CGFloat) {
        let centre = CGPoint(x: side / 2, y: side / 2)
        let inner = side * 0.16
        let outer = side * 0.44
        let maxCount = max(1, slices.map { $0.count }.max() ?? 1)

        var ring = Path()
        ring.addEllipse(in: CGRect(x: centre.x - inner, y: centre.y - inner, width: inner * 2, height: inner * 2))
        context.stroke(ring, with: .color(TEPalette.line), style: StrokeStyle(lineWidth: 1))

        var guideRing = Path()
        guideRing.addEllipse(in: CGRect(x: centre.x - outer, y: centre.y - outer, width: outer * 2, height: outer * 2))
        context.stroke(guideRing, with: .color(TEPalette.line.opacity(0.8)), style: StrokeStyle(lineWidth: 1))

        for slice in slices {
            guard slice.count > 0 else { continue }
            let fraction = teSafeDivide(Double(slice.count), Double(maxCount))
            let length = inner + (outer - inner) * CGFloat(fraction)
            let angle = (Double(slice.hour) / 24.0) * 2 * Double.pi - Double.pi / 2
            let start = CGPoint(x: centre.x + cos(angle) * inner, y: centre.y + sin(angle) * inner)
            let end = CGPoint(x: centre.x + cos(angle) * length, y: centre.y + sin(angle) * length)
            var spoke = Path()
            spoke.move(to: start)
            spoke.addLine(to: end)
            let tint = TEPalette.intensity(Int(slice.meanIntensity.rounded()))
            context.stroke(spoke, with: .color(tint), style: StrokeStyle(lineWidth: side * 0.036, lineCap: .round))
        }

        let markers: [(Int, String)] = [(0, "00"), (6, "06"), (12, "12"), (18, "18")]
        for marker in markers {
            let angle = (Double(marker.0) / 24.0) * 2 * Double.pi - Double.pi / 2
            let point = CGPoint(x: centre.x + cos(angle) * (outer + side * 0.06),
                                y: centre.y + sin(angle) * (outer + side * 0.06))
            let resolved = context.resolve(Text(marker.1)
                .font(TEType.body(side * 0.062))
                .foregroundColor(TEPalette.inkFaint))
            context.draw(resolved, at: point, anchor: .center)
        }
    }
}

// MARK: - Decorative header artwork

/// Quiet line-work: a wave being absorbed into a soft shape. Used at the top of Plan and
/// on the onboarding screens.
struct TEAbsorbArt: View {
    var width: CGFloat
    var height: CGFloat = 90
    var tint: Color = TEPalette.moss

    var body: some View {
        Canvas { context, _ in
            draw(&context, width: width, height: height)
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }

    private func draw(_ context: inout GraphicsContext, width: CGFloat, height: CGFloat) {
        guard width > 10, height > 10 else { return }
        let midY = height * 0.55

        // Incoming wave from the left, decaying as it approaches the cushion.
        var wave = Path()
        let steps = 90
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = width * 0.04 + t * width * 0.55
            let decay = CGFloat(pow(Double(1 - t), 1.7))
            let y = midY + sin(Double(t) * 14) * Double(height * 0.24 * decay)
            let point = CGPoint(x: x, y: CGFloat(y))
            if i == 0 { wave.move(to: point) } else { wave.addLine(to: point) }
        }
        context.stroke(wave, with: .color(tint.opacity(0.75)),
                       style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

        // The cushion / leaf it lands in.
        var cushion = Path()
        let left = width * 0.58
        let right = width * 0.95
        cushion.move(to: CGPoint(x: left, y: midY))
        cushion.addCurve(to: CGPoint(x: right, y: midY),
                         control1: CGPoint(x: left + (right - left) * 0.15, y: midY - height * 0.42),
                         control2: CGPoint(x: right - (right - left) * 0.15, y: midY - height * 0.42))
        cushion.addCurve(to: CGPoint(x: left, y: midY),
                         control1: CGPoint(x: right - (right - left) * 0.15, y: midY + height * 0.42),
                         control2: CGPoint(x: left + (right - left) * 0.15, y: midY + height * 0.42))
        context.fill(cushion, with: .color(tint.opacity(0.16)))
        context.stroke(cushion, with: .color(tint.opacity(0.7)), style: StrokeStyle(lineWidth: 1.6))

        var vein = Path()
        vein.move(to: CGPoint(x: left + (right - left) * 0.12, y: midY))
        vein.addLine(to: CGPoint(x: right - (right - left) * 0.10, y: midY))
        context.stroke(vein, with: .color(tint.opacity(0.45)), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
    }
}
