import SwiftUI

// Shared building blocks. Every screen in the app is assembled from these so spacing,
// safe areas and scroll insets behave identically everywhere.

// MARK: - Status bar strip

/// An opaque band that fills the top safe area. Always the LAST sibling in a screen's ZStack,
/// so scrolled content can never draw over the clock.
struct TEStatusStrip: View {
    var color: Color = TEPalette.sand
    var body: some View {
        VStack(spacing: 0) {
            color.frame(height: max(0, TEMetrics.topSafeInset))
            Spacer(minLength: 0)
        }
        .edgesIgnoringSafeArea(.top)
        .allowsHitTesting(false)
    }
}

// MARK: - Page scaffold

struct TEPage<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var onBack: (() -> Void)? = nil
    var trailing: AnyView? = nil
    var bottomInset: CGFloat = TEMetrics.scrollBottomInset
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .top) {
            TEPalette.sand.edgesIgnoringSafeArea(.all)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    content()
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, bottomInset)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            TEStatusStrip()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 10) {
                if let onBack = onBack {
                    Button(action: onBack) {
                        HStack(spacing: 3) {
                            TEGlyph(kind: .chevronLeft, size: 18, color: TEPalette.mossDeep)
                            Text("Back")
                                .font(TEType.medium(15))
                                .foregroundColor(TEPalette.mossDeep)
                        }
                        .padding(.vertical, 6)
                        .padding(.trailing, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer(minLength: 0)
                if let trailing = trailing { trailing }
            }
            .frame(minHeight: onBack == nil && trailing == nil ? 0 : 30)

            Text(title)
                .font(TEType.display(TEMetrics.isNarrow ? 26 : 29))
                .foregroundColor(TEPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(TEType.body(14))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.bottom, 2)
    }
}

// MARK: - Cards

struct TECard<Content: View>: View {
    var padding: CGFloat = 16
    var background: Color = TEPalette.card
    var border: Color = TEPalette.cardEdge
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(border, lineWidth: 1)
        )
    }
}

struct TESectionHeader: View {
    let title: String
    var note: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(title.uppercased())
                    .font(TEType.medium(12))
                    .tracking(1.1)
                    .foregroundColor(TEPalette.inkFaint)
                Spacer(minLength: 0)
                if let note = note {
                    Text(note)
                        .font(TEType.body(11))
                        .foregroundColor(TEPalette.inkFaint)
                }
            }
            TEQuietRule()
        }
        .padding(.top, 6)
    }
}

/// Small inline note used for disclaimers and sample-count caveats.
struct TEFootnote: View {
    let text: String
    var body: some View {
        Text(text)
            .font(TEType.body(11.5))
            .foregroundColor(TEPalette.inkFaint)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct TEDisclaimerCard: View {
    var compact: Bool = false
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            TEGlyph(kind: .info, size: 18, color: TEPalette.clayDeep)
            Text(compact
                 ? "Self-tracking only. Trigger Ease is not a medical device and does not provide medical advice."
                 : "Trigger Ease is a self-tracking and preparation tool. It is not a medical device, it does not diagnose anything, and it does not provide medical advice. If this is affecting your sleep, work, study or relationships, speak to a qualified clinician — an audiologist, a psychologist or a physician.")
                .font(TEType.body(12.5))
                .foregroundColor(TEPalette.clayDeep)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TEPalette.claySoft.opacity(0.55))
        )
    }
}

// MARK: - Buttons

struct TEPrimaryButton: View {
    let title: String
    var glyph: TEGlyphKind? = nil
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: { if enabled { action() } }) {
            HStack(spacing: 8) {
                if let glyph = glyph {
                    TEGlyph(kind: glyph, size: 18, color: TEPalette.card)
                }
                Text(title)
                    .font(TEType.title(16))
                    .foregroundColor(TEPalette.card)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(enabled ? TEPalette.moss : TEPalette.moss.opacity(0.35))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TESecondaryButton: View {
    let title: String
    var glyph: TEGlyphKind? = nil
    var tint: Color = TEPalette.mossDeep
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let glyph = glyph {
                    TEGlyph(kind: glyph, size: 17, color: tint)
                }
                Text(title)
                    .font(TEType.medium(15))
                    .foregroundColor(tint)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(tint.opacity(0.4), lineWidth: 1.2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Chips

struct TEChip: View {
    let title: String
    var selected: Bool
    var tint: Color = TEPalette.moss
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TEType.medium(13))
                .foregroundColor(selected ? TEPalette.card : TEPalette.inkSoft)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(selected ? tint : TEPalette.card)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(selected ? tint : TEPalette.cardEdge, lineWidth: 1)
                )
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Wrapping chip row. Rows are packed greedily against the width the caller passes in,
/// after every horizontal inset has been subtracted, so long labels cannot overflow.
struct TEChipFlow: View {
    let items: [String]
    let isSelected: (String) -> Bool
    let onTap: (String) -> Void
    var tint: Color = TEPalette.moss
    var availableWidth: CGFloat = TEMetrics.screenWidth - 36

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows.indices, id: \.self) { index in
                HStack(spacing: 8) {
                    ForEach(rows[index], id: \.self) { item in
                        TEChip(title: item, selected: isSelected(item), tint: tint) { onTap(item) }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    /// Conservative width estimate for a chip: label plus its horizontal padding.
    private func estimatedWidth(_ title: String) -> CGFloat {
        CGFloat(title.count) * 7.6 + 28
    }

    private var rows: [[String]] {
        let limit = max(80, availableWidth)
        var result: [[String]] = []
        var current: [String] = []
        var used: CGFloat = 0
        for item in items {
            let width = min(limit, estimatedWidth(item))
            let extra = current.isEmpty ? width : width + 8
            if used + extra > limit && !current.isEmpty {
                result.append(current)
                current = [item]
                used = width
            } else {
                current.append(item)
                used += extra
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }
}

// MARK: - Scales

/// Eleven-point 0...10 picker — the primary input control in the app. Cells flex, so it never
/// overflows a narrow screen, and every cell clears the 44 pt minimum height. On a narrow device
/// eleven cells across would be about 25 pt wide, so the row is split 6 + 5 instead.
struct TEScalePicker: View {
    let value: Int
    var lowLabel: String = "0"
    var highLabel: String = "10"
    var tintByValue: Bool = true
    let onChange: (Int) -> Void

    private static let cellHeight: CGFloat = 44

    private var rows: [[Int]] {
        TEMetrics.isNarrow ? [Array(0...5), Array(6...10)] : [Array(0...10)]
    }

    private var widestRow: Int { rows.map { $0.count }.max() ?? 1 }

    private var cellSpacing: CGFloat { TEMetrics.isNarrow ? 6 : 3 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(spacing: cellSpacing) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: cellSpacing) {
                        ForEach(rows[rowIndex], id: \.self) { index in
                            cell(index)
                        }
                        // Keeps the short row's cells the same width as the long row's.
                        if rows[rowIndex].count < widestRow {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: Self.cellHeight)
                        }
                    }
                }
            }
            HStack {
                Text(lowLabel)
                    .font(TEType.body(11))
                    .foregroundColor(TEPalette.inkFaint)
                Spacer(minLength: 0)
                Text(highLabel)
                    .font(TEType.body(11))
                    .foregroundColor(TEPalette.inkFaint)
            }
        }
    }

    private func cell(_ index: Int) -> some View {
        Button(action: { onChange(index) }) {
            Text("\(index)")
                .font(TEType.medium(index == value ? 15 : 13.5))
                .foregroundColor(foreground(index))
                .frame(maxWidth: .infinity)
                .frame(height: Self.cellHeight)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(background(index))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(index == value ? TEPalette.ink.opacity(0.45) : TEPalette.cardEdge,
                                lineWidth: index == value ? 1.6 : 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func background(_ index: Int) -> Color {
        if index == value {
            return tintByValue ? TEPalette.intensity(index) : TEPalette.moss
        }
        return TEPalette.card
    }

    private func foreground(_ index: Int) -> Color {
        if index == value {
            return tintByValue ? TEPalette.intensityInk(index) : TEPalette.card
        }
        return TEPalette.inkSoft
    }
}

/// Compact stepper for minute values, avoiding a numeric keyboard entirely.
struct TEMinuteStepper: View {
    let value: Int
    let steps: [Int]
    let onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(steps, id: \.self) { step in
                Button(action: { onChange(step) }) {
                    Text(label(step))
                        .font(TEType.medium(12.5))
                        .foregroundColor(step == value ? TEPalette.card : TEPalette.inkSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(step == value ? TEPalette.moss : TEPalette.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(step == value ? TEPalette.moss : TEPalette.cardEdge, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func label(_ minutes: Int) -> String {
        if minutes == 0 { return "Off" }
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        return "\(h)h"
    }
}

struct TEToggleRow: View {
    let title: String
    var detail: String? = nil
    let isOn: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        Button(action: { onToggle(!isOn) }) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(TEType.medium(15))
                        .foregroundColor(TEPalette.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let detail = detail {
                        Text(detail)
                            .font(TEType.body(12))
                            .foregroundColor(TEPalette.inkSoft)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)
                TESwitchShape(isOn: isOn)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Custom switch — no system control anywhere in the app.
struct TESwitchShape: View {
    let isOn: Bool
    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule(style: .continuous)
                .fill(isOn ? TEPalette.moss : TEPalette.sandDeep)
                .frame(width: 48, height: 28)
            Circle()
                .fill(TEPalette.card)
                .frame(width: 22, height: 22)
                .padding(.horizontal, 3)
        }
        .frame(width: 48, height: 28)
        .animation(.easeInOut(duration: 0.16), value: isOn)
    }
}

// MARK: - Empty and error states

struct TEEmptyState: View {
    let glyph: TEGlyphKind
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            TEGlyph(kind: glyph, size: 42, color: TEPalette.moss.opacity(0.55), weight: 1.5)
            Text(title)
                .font(TEType.title(17))
                .foregroundColor(TEPalette.ink)
                .multilineTextAlignment(.center)
            Text(message)
                .font(TEType.body(13.5))
                .foregroundColor(TEPalette.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle = actionTitle, let action = action {
                TEPrimaryButton(title: actionTitle, action: action)
                    .padding(.top, 4)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 26)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TEPalette.card.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TEPalette.cardEdge, lineWidth: 1)
        )
    }
}

struct TENotEnoughData: View {
    let needed: Int
    let have: Int
    var noun: String = "entries"
    var body: some View {
        HStack(spacing: 8) {
            TEGlyph(kind: .chart, size: 16, color: TEPalette.inkFaint)
            Text("Not enough data yet — \(have) of \(needed) \(noun).")
                .font(TEType.body(12.5))
                .foregroundColor(TEPalette.inkFaint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Text entry

/// One identifier space for every text field in the app. Multi-field SwiftUI forms need
/// explicit focus management or only the first field will accept a tap.
enum TEFieldID: Hashable {
    case planName
    case planSeating
    case planExit
    case planSupport
    case planNote
    case episodePlace
    case episodeNote
    case runNote
    case ladderNote
    case search
}

struct TETextField: View {
    let placeholder: String
    @Binding var text: String
    var focus: FocusState<TEFieldID?>.Binding
    let field: TEFieldID
    var submitLabel: String? = nil

    private var isFocused: Bool { focus.wrappedValue == field }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(TEType.body(15))
                    .foregroundColor(TEPalette.inkFaint)
                    .lineLimit(1)
                    .allowsHitTesting(false)
                    .padding(.horizontal, 13)
            }
            TextField("", text: $text)
                .font(TEType.body(15))
                .foregroundColor(TEPalette.ink)
                .accentColor(TEPalette.moss)
                .focused(focus, equals: field)
                .padding(.horizontal, 13)
        }
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(TEPalette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(isFocused ? TEPalette.moss : TEPalette.cardEdge, lineWidth: isFocused ? 1.6 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { focus.wrappedValue = field }
    }
}

struct TETextArea: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 90
    var focus: FocusState<TEFieldID?>.Binding
    let field: TEFieldID

    private var isFocused: Bool { focus.wrappedValue == field }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(TEPalette.card)
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(isFocused ? TEPalette.moss : TEPalette.cardEdge, lineWidth: isFocused ? 1.6 : 1)
            if text.isEmpty {
                Text(placeholder)
                    .font(TEType.body(14))
                    .foregroundColor(TEPalette.inkFaint)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
                    .fixedSize(horizontal: false, vertical: true)
            }
            TextEditor(text: $text)
                .font(TEType.body(14))
                .foregroundColor(TEPalette.ink)
                .accentColor(TEPalette.moss)
                .focused(focus, equals: field)
                .padding(.horizontal, 9)
                .padding(.vertical, 7)
                .background(Color.clear)
        }
        .frame(minHeight: minHeight)
        .contentShape(Rectangle())
        .onTapGesture { focus.wrappedValue = field }
    }
}

/// Search field used by the trigger, technique and learn lists.
struct TESearchField: View {
    let placeholder: String
    @Binding var text: String
    var focus: FocusState<TEFieldID?>.Binding

    var body: some View {
        HStack(spacing: 9) {
            TEGlyph(kind: .search, size: 16, color: TEPalette.inkFaint)
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(TEType.body(14.5))
                        .foregroundColor(TEPalette.inkFaint)
                        .lineLimit(1)
                        .allowsHitTesting(false)
                }
                TextField("", text: $text)
                    .font(TEType.body(14.5))
                    .foregroundColor(TEPalette.ink)
                    .accentColor(TEPalette.moss)
                    .focused(focus, equals: .search)
            }
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    TEGlyph(kind: .close, size: 15, color: TEPalette.inkFaint)
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 13)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(TEPalette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(focus.wrappedValue == .search ? TEPalette.moss : TEPalette.cardEdge,
                        lineWidth: focus.wrappedValue == .search ? 1.6 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { focus.wrappedValue = .search }
    }
}

// MARK: - Navigation row

/// A push row that looks like a card. The whole card is the tap target.
struct TENavRow<Destination: View, Leading: View>: View {
    var title: String
    var detail: String? = nil
    var badge: String? = nil
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 12) {
                leading()
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(TEType.medium(15.5))
                        .foregroundColor(TEPalette.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let detail = detail, !detail.isEmpty {
                        Text(detail)
                            .font(TEType.body(12.5))
                            .foregroundColor(TEPalette.inkSoft)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 4)
                if let badge = badge {
                    Text(badge)
                        .font(TEType.medium(11))
                        .foregroundColor(TEPalette.card)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule(style: .continuous).fill(TEPalette.clay))
                }
                TEGlyph(kind: .chevronRight, size: 16, color: TEPalette.inkFaint)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(TEPalette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(TEPalette.cardEdge, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// A small round glyph badge used as the leading element of rows.
struct TERowBadge: View {
    let glyph: TEGlyphKind
    var tint: Color = TEPalette.moss
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.14))
            TEGlyph(kind: glyph, size: size * 0.55, color: tint, weight: 1.7)
        }
        .frame(width: size, height: size)
    }
}

/// Intensity pip used in lists.
struct TEIntensityPip: View {
    let value: Int
    var size: CGFloat = 34
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TEPalette.intensity(value))
            Text("\(value)")
                .font(TEType.mono(13))
                .foregroundColor(TEPalette.intensityInk(value))
        }
        .frame(width: size, height: size)
    }
}
