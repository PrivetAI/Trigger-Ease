import Foundation

/// Every number the Journal shows is computed here. Sample counts travel with each figure so
/// the UI can print them, and anything below `minimumSamples` is reported as insufficient data.
enum TEAnalytics {

    static let minimumSamples = 5

    struct Bucket: Identifiable, Hashable {
        var id: String { key }
        let key: String
        let label: String
        let mean: Double
        let count: Int
        var confident: Bool { count >= TEAnalytics.minimumSamples }
    }

    struct DayPoint: Identifiable, Hashable {
        var id: Int { dayKey }
        let dayKey: Int
        let date: Date
        let count: Int
        let meanIntensity: Double
    }

    struct HourSlice: Identifiable, Hashable {
        var id: Int { hour }
        let hour: Int
        let count: Int
        let meanIntensity: Double
    }

    // MARK: - Worst triggers

    static func triggerRanking(_ episodes: [TEEpisode]) -> [Bucket] {
        var buckets: [String: [Double]] = [:]
        for episode in episodes where !episode.triggerID.isEmpty {
            buckets[episode.triggerID, default: []].append(Double(clamp(episode.intensity)))
        }
        return buckets.compactMap { key, values -> Bucket? in
            guard let trigger = TETriggerCatalog.byID(key), let mean = teMean(values) else { return nil }
            return Bucket(key: key, label: trigger.name, mean: mean, count: values.count)
        }
        .sorted(by: severitySort)
    }

    // MARK: - Worst contexts

    static func placeRanking(_ episodes: [TEEpisode]) -> [Bucket] {
        var buckets: [String: [Double]] = [:]
        for episode in episodes {
            let place = episode.place.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !place.isEmpty else { continue }
            buckets[place.lowercased(), default: []].append(Double(clamp(episode.intensity)))
        }
        var labels: [String: String] = [:]
        for episode in episodes {
            let place = episode.place.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !place.isEmpty else { continue }
            labels[place.lowercased()] = place
        }
        return buckets.compactMap { key, values -> Bucket? in
            guard let mean = teMean(values) else { return nil }
            return Bucket(key: key, label: labels[key] ?? key, mean: mean, count: values.count)
        }
        .sorted(by: severitySort)
    }

    static func roleRanking(_ episodes: [TEEpisode]) -> [Bucket] {
        var buckets: [TEPersonRole: [Double]] = [:]
        for episode in episodes {
            buckets[episode.role, default: []].append(Double(clamp(episode.intensity)))
        }
        return buckets.compactMap { key, values -> Bucket? in
            guard let mean = teMean(values) else { return nil }
            return Bucket(key: key.rawValue, label: key.title, mean: mean, count: values.count)
        }
        .sorted(by: severitySort)
    }

    static func classRanking(_ episodes: [TEEpisode]) -> [Bucket] {
        var buckets: [TETriggerClass: [Double]] = [:]
        for episode in episodes {
            guard let trigger = TETriggerCatalog.byID(episode.triggerID) else { continue }
            buckets[trigger.triggerClass, default: []].append(Double(clamp(episode.intensity)))
        }
        return buckets.compactMap { key, values -> Bucket? in
            guard let mean = teMean(values) else { return nil }
            return Bucket(key: key.rawValue, label: key.shortTitle, mean: mean, count: values.count)
        }
        .sorted(by: severitySort)
    }

    // MARK: - Responses

    /// Which response the user reaches for most, and the mean recovery time that follows it.
    static func responseRecovery(_ episodes: [TEEpisode]) -> [Bucket] {
        var buckets: [TEResponse: [Double]] = [:]
        for episode in episodes {
            buckets[episode.response, default: []].append(Double(max(0, episode.recoveryMinutes)))
        }
        return buckets.compactMap { key, values -> Bucket? in
            guard let mean = teMean(values) else { return nil }
            return Bucket(key: key.rawValue, label: key.title, mean: mean, count: values.count)
        }
        .sorted { lhs, rhs in
            if lhs.count != rhs.count { return lhs.count > rhs.count }
            return lhs.mean < rhs.mean
        }
    }

    static func responseUsage(_ episodes: [TEEpisode]) -> [Bucket] {
        var counts: [TEResponse: Int] = [:]
        for episode in episodes { counts[episode.response, default: 0] += 1 }
        let total = max(1, episodes.count)
        return counts.map { key, value in
            Bucket(key: key.rawValue, label: key.title,
                   mean: teSafeDivide(Double(value) * 100, Double(total)), count: value)
        }
        .sorted { $0.count > $1.count }
    }

    /// The response followed by the shortest mean recovery, among responses with enough samples.
    static func shortestRecoveryResponse(_ episodes: [TEEpisode]) -> Bucket? {
        responseRecovery(episodes).filter { $0.confident }.min { $0.mean < $1.mean }
    }

    // MARK: - Physical signs

    static func physicalRanking(_ episodes: [TEEpisode]) -> [Bucket] {
        var counts: [TEPhysicalSign: Int] = [:]
        var intensities: [TEPhysicalSign: [Double]] = [:]
        for episode in episodes {
            for sign in episode.physical {
                counts[sign, default: 0] += 1
                intensities[sign, default: []].append(Double(clamp(episode.intensity)))
            }
        }
        return counts.map { key, value in
            Bucket(key: key.rawValue, label: key.title,
                   mean: teMean(intensities[key] ?? []) ?? 0, count: value)
        }
        .sorted { $0.count > $1.count }
    }

    // MARK: - Time of day

    static func hourDistribution(_ episodes: [TEEpisode]) -> [HourSlice] {
        var counts = Array(repeating: 0, count: 24)
        var sums = Array(repeating: 0.0, count: 24)
        for episode in episodes {
            let h = max(0, min(23, teHour(episode.date)))
            counts[h] += 1
            sums[h] += Double(clamp(episode.intensity))
        }
        return (0..<24).map { hour in
            HourSlice(hour: hour, count: counts[hour],
                      meanIntensity: teSafeDivide(sums[hour], Double(counts[hour])))
        }
    }

    /// Coarse four-way split, which reads better than 24 bars on a narrow screen.
    static func partOfDay(_ episodes: [TEEpisode]) -> [Bucket] {
        var buckets: [String: [Double]] = [:]
        for episode in episodes {
            let h = teHour(episode.date)
            let key: String
            switch h {
            case 5..<11: key = "Morning"
            case 11..<16: key = "Midday"
            case 16..<22: key = "Evening"
            default: key = "Night"
            }
            buckets[key, default: []].append(Double(clamp(episode.intensity)))
        }
        let order = ["Morning", "Midday", "Evening", "Night"]
        return order.compactMap { key in
            guard let values = buckets[key], let mean = teMean(values) else { return nil }
            return Bucket(key: key, label: key, mean: mean, count: values.count)
        }
    }

    // MARK: - Trends

    /// One point per day over the last `days`, including empty days so the line has real spacing.
    static func dailySeries(_ episodes: [TEEpisode], days: Int) -> [DayPoint] {
        let span = max(1, min(120, days))
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        let today = teStartOfDay(Date())
        var grouped: [Int: [Double]] = [:]
        for episode in episodes {
            grouped[teDayKey(episode.date), default: []].append(Double(clamp(episode.intensity)))
        }
        var points: [DayPoint] = []
        for offset in stride(from: span - 1, through: 0, by: -1) {
            guard let date = cal.date(byAdding: .day, value: -offset, to: today) else { continue }
            let key = teDayKey(date)
            let values = grouped[key] ?? []
            points.append(DayPoint(dayKey: key, date: date, count: values.count,
                                   meanIntensity: teMean(values) ?? 0))
        }
        return points
    }

    /// Weekly means over the last `weeks` calendar weeks, oldest first.
    static func weeklyIntensity(_ episodes: [TEEpisode], weeks: Int) -> [Bucket] {
        let span = max(1, min(26, weeks))
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        let today = teStartOfDay(Date())
        var result: [Bucket] = []
        for index in stride(from: span - 1, through: 0, by: -1) {
            guard let end = cal.date(byAdding: .day, value: -7 * index, to: today),
                  let start = cal.date(byAdding: .day, value: -6, to: end) else { continue }
            let window = episodes.filter { $0.date >= start && $0.date < end.addingTimeInterval(86400) }
            let mean = teMean(window.map { Double(clamp($0.intensity)) }) ?? 0
            let label = index == 0 ? "This week" : "\(index)w ago"
            result.append(Bucket(key: "w\(index)", label: label, mean: mean, count: window.count))
        }
        return result
    }

    static func weeklyRecovery(_ episodes: [TEEpisode], weeks: Int) -> [Bucket] {
        let span = max(1, min(26, weeks))
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        let today = teStartOfDay(Date())
        var result: [Bucket] = []
        for index in stride(from: span - 1, through: 0, by: -1) {
            guard let end = cal.date(byAdding: .day, value: -7 * index, to: today),
                  let start = cal.date(byAdding: .day, value: -6, to: end) else { continue }
            let window = episodes.filter { $0.date >= start && $0.date < end.addingTimeInterval(86400) }
            let mean = teMean(window.map { Double(max(0, $0.recoveryMinutes)) }) ?? 0
            let label = index == 0 ? "This week" : "\(index)w ago"
            result.append(Bucket(key: "r\(index)", label: label, mean: mean, count: window.count))
        }
        return result
    }

    // MARK: - Headline figures

    struct Headline {
        let total: Int
        let meanIntensity: Double?
        let meanRecovery: Double?
        let last7: Int
        let previous7: Int
        let worstTrigger: String?
    }

    static func headline(_ episodes: [TEEpisode]) -> Headline {
        let now = Date()
        let week = now.addingTimeInterval(-7 * 86400)
        let twoWeeks = now.addingTimeInterval(-14 * 86400)
        let last7 = episodes.filter { $0.date >= week }.count
        let previous7 = episodes.filter { $0.date >= twoWeeks && $0.date < week }.count
        let worst = triggerRanking(episodes).first(where: { $0.count >= 2 })?.label
            ?? triggerRanking(episodes).first?.label
        return Headline(total: episodes.count,
                        meanIntensity: teMean(episodes.map { Double(clamp($0.intensity)) }),
                        meanRecovery: teMean(episodes.map { Double(max(0, $0.recoveryMinutes)) }),
                        last7: last7,
                        previous7: previous7,
                        worstTrigger: worst)
    }

    // MARK: - Per trigger

    struct TriggerProfile {
        let count: Int
        let meanIntensity: Double?
        let meanRecovery: Double?
        let topPlaces: [Bucket]
        let topRoles: [Bucket]
        let lastSeen: Date?
    }

    static func profile(for triggerID: String, episodes: [TEEpisode]) -> TriggerProfile {
        let matching = episodes.filter { $0.triggerID == triggerID }
        return TriggerProfile(
            count: matching.count,
            meanIntensity: teMean(matching.map { Double(clamp($0.intensity)) }),
            meanRecovery: teMean(matching.map { Double(max(0, $0.recoveryMinutes)) }),
            topPlaces: Array(placeRanking(matching).prefix(3)),
            topRoles: Array(roleRanking(matching).prefix(3)),
            lastSeen: matching.map { $0.date }.max())
    }

    // MARK: - Helpers

    private static func clamp(_ value: Int) -> Int { max(0, min(10, value)) }

    private static func severitySort(_ lhs: Bucket, _ rhs: Bucket) -> Bool {
        if abs(lhs.mean - rhs.mean) > 0.001 { return lhs.mean > rhs.mean }
        return lhs.count > rhs.count
    }
}
