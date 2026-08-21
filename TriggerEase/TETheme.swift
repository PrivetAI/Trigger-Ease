import SwiftUI

// Trigger Ease — visual identity.
// Muted moss green, warm clay, soft sand, deep charcoal text, restrained rust for high intensity.
// Deliberately a calm notebook: soft rounded cards, generous spacing, quiet line-work.

enum TEPalette {
    static let sand = Color(red: 0.949, green: 0.925, blue: 0.878)
    /// Same colour as `sand`, for the UIKit-backed web panel.
    static let sandUI = UIColor(red: 0.949, green: 0.925, blue: 0.878, alpha: 1)
    static let sandDeep = Color(red: 0.906, green: 0.871, blue: 0.808)
    static let card = Color(red: 0.988, green: 0.973, blue: 0.945)
    static let cardEdge = Color(red: 0.871, green: 0.835, blue: 0.769)

    static let moss = Color(red: 0.431, green: 0.498, blue: 0.361)
    static let mossDeep = Color(red: 0.302, green: 0.357, blue: 0.251)
    static let mossSoft = Color(red: 0.812, green: 0.843, blue: 0.776)

    static let clay = Color(red: 0.753, green: 0.541, blue: 0.416)
    static let claySoft = Color(red: 0.933, green: 0.867, blue: 0.812)
    static let clayDeep = Color(red: 0.596, green: 0.408, blue: 0.294)

    static let rust = Color(red: 0.706, green: 0.333, blue: 0.227)
    static let rustSoft = Color(red: 0.933, green: 0.812, blue: 0.780)

    static let ink = Color(red: 0.180, green: 0.173, blue: 0.157)
    static let inkSoft = Color(red: 0.361, green: 0.345, blue: 0.318)
    static let inkFaint = Color(red: 0.545, green: 0.522, blue: 0.482)
    static let line = Color(red: 0.871, green: 0.831, blue: 0.765)

    /// Intensity 0...10 mapped onto the calm-to-rust ramp.
    static func intensity(_ value: Int) -> Color {
        let v = max(0, min(10, value))
        switch v {
        case 0: return Color(red: 0.831, green: 0.847, blue: 0.808)
        case 1...2: return mossSoft
        case 3...4: return Color(red: 0.706, green: 0.745, blue: 0.639)
        case 5...6: return Color(red: 0.831, green: 0.706, blue: 0.549)
        case 7...8: return clay
        default: return rust
        }
    }

    static func intensityInk(_ value: Int) -> Color {
        return value >= 7 ? Color.white : ink
    }
}

enum TEType {
    static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func body(_ size: CGFloat) -> Font { .system(size: size, weight: .regular, design: .rounded) }
    static func medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium, design: .rounded) }
    static func mono(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .monospaced) }
}

enum TEMetrics {
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    /// True on the 375x667 class of device, where fixed hero layouts collapse.
    static var isCompactHeight: Bool { UIScreen.main.bounds.height <= 700 }
    static var isNarrow: Bool { UIScreen.main.bounds.width <= 380 }

    static let tabBarHeight: CGFloat = 62
    /// Bottom padding every scroll container uses so the floating tab row never hides a row.
    static let scrollBottomInset: CGFloat = 62 + 26

    static var topSafeInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        for scene in scenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows where window.isKeyWindow {
                    return window.safeAreaInsets.top
                }
            }
        }
        return 20
    }
}

enum TEFormat {
    static let dayMonth: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "d MMM"
        return f
    }()

    static let fullDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f
    }()

    static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "d MMM yyyy"
        return f
    }()

    static let dateTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "d MMM yyyy 'at' HH:mm"
        return f
    }()

    static let clock: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "HH:mm"
        return f
    }()

    static let weekday: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE"
        return f
    }()

    static let oneDecimal: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.numberStyle = .decimal
        f.minimumFractionDigits = 1
        f.maximumFractionDigits = 1
        return f
    }()

    static func decimal(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        return oneDecimal.string(from: NSNumber(value: value)) ?? "—"
    }

    /// Minutes rendered as a compact human duration.
    static func duration(_ minutes: Int) -> String {
        if minutes <= 0 { return "—" }
        if minutes < 60 { return "\(minutes) min" }
        let h = minutes / 60
        let m = minutes % 60
        if m == 0 { return "\(h) h" }
        return "\(h) h \(m) min"
    }
}

/// Every division in the app goes through here. NaN and Infinity never reach the UI.
func teSafeDivide(_ numerator: Double, _ denominator: Double, fallback: Double = 0) -> Double {
    guard denominator != 0, denominator.isFinite, numerator.isFinite else { return fallback }
    let result = numerator / denominator
    return result.isFinite ? result : fallback
}

func teMean(_ values: [Double]) -> Double? {
    guard !values.isEmpty else { return nil }
    return teSafeDivide(values.reduce(0, +), Double(values.count))
}

func teDayKey(_ date: Date) -> Int {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "en_US_POSIX")
    let c = cal.dateComponents([.year, .month, .day], from: date)
    let y = c.year ?? 2000
    let m = c.month ?? 1
    let d = c.day ?? 1
    return y * 10000 + m * 100 + d
}

func teStartOfDay(_ date: Date) -> Date {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "en_US_POSIX")
    return cal.startOfDay(for: date)
}

func teHour(_ date: Date) -> Int {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "en_US_POSIX")
    return cal.component(.hour, from: date)
}

func teDaysBetween(_ a: Date, _ b: Date) -> Int {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "en_US_POSIX")
    let comps = cal.dateComponents([.day], from: teStartOfDay(a), to: teStartOfDay(b))
    return comps.day ?? 0
}
