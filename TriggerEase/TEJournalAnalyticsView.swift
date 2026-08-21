import SwiftUI

struct TEJournalAnalyticsView: View {
    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var windowDays = 90

    private var episodes: [TEEpisode] {
        guard windowDays > 0 else { return store.episodes }
        let cutoff = Date().addingTimeInterval(-Double(windowDays) * 86400)
        return store.episodes.filter { $0.date >= cutoff }
    }

    var body: some View {
        TEPage(title: "Analytics",
               subtitle: "Sample counts are printed next to every figure. Below \(TEAnalytics.minimumSamples) entries the app says so rather than drawing a conclusion.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            windowPicker

            if episodes.count < 2 {
                TEEmptyState(glyph: .chart,
                             title: "Not much to show yet",
                             message: "There are \(episodes.count) \(episodes.count == 1 ? "entry" : "entries") in this window. A handful of entries is enough for the first patterns to appear.")
            } else {
                weeklyTrendSection
                triggerSection
                classSection
                contextSection
                roleSection
                timeSection
                responseSection
                physicalSection
                recoverySection
            }

            TEDisclaimerCard(compact: true)
        }
    }

    private var windowPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                TEChip(title: "30 days", selected: windowDays == 30) { windowDays = 30 }
                TEChip(title: "90 days", selected: windowDays == 90) { windowDays = 90 }
                TEChip(title: "180 days", selected: windowDays == 180) { windowDays = 180 }
                TEChip(title: "All time", selected: windowDays == 0) { windowDays = 0 }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Weekly trend

    private var weeklyTrendSection: some View {
        Group {
            let weeks = TEAnalytics.weeklyIntensity(episodes, weeks: 8)
            TESectionHeader(title: "Weekly intensity", note: "last 8 weeks")
            TECard {
                TEBarChart(values: weeks.map { $0.mean },
                           labels: weeks.map { shortWeekLabel($0.label) },
                           counts: weeks.map { $0.count },
                           maxValue: 10,
                           height: 120,
                           intensityTinted: true)
                Text(weekNarrative(weeks))
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                TEFootnote(text: "Entry counts by week: " + weeks.map { "\($0.count)" }.joined(separator: ", ") + ". Weeks with no entries are drawn flat, not as zero intensity.")
            }

            let daily = TEAnalytics.dailySeries(episodes, days: min(60, max(14, windowDays == 0 ? 60 : windowDays)))
            TESectionHeader(title: "Day by day", note: "\(daily.count) days")
            TECard {
                TELineChart(points: daily.map { $0.meanIntensity },
                            counts: daily.map { $0.count },
                            maxValue: 10,
                            height: 130,
                            tint: TEPalette.clay)
                HStack {
                    Text(TEFormat.dayMonth.string(from: daily.first?.date ?? Date()))
                        .font(TEType.body(10.5))
                        .foregroundColor(TEPalette.inkFaint)
                    Spacer(minLength: 0)
                    Text("today")
                        .font(TEType.body(10.5))
                        .foregroundColor(TEPalette.inkFaint)
                }
                TEFootnote(text: "Mean intensity per day. Days without an entry sit on the baseline and carry no dot.")
            }
        }
    }

    private func shortWeekLabel(_ label: String) -> String {
        label == "This week" ? "now" : label.replacingOccurrences(of: " ago", with: "")
    }

    private func weekNarrative(_ weeks: [TEAnalytics.Bucket]) -> String {
        let withData = weeks.filter { $0.count > 0 }
        guard withData.count >= 2 else {
            return "Not enough weeks with entries yet to describe a direction."
        }
        let half = withData.count / 2
        let early = teMean(withData.prefix(half).map { $0.mean }) ?? 0
        let late = teMean(withData.suffix(withData.count - half).map { $0.mean }) ?? 0
        let difference = late - early
        let totals = withData.reduce(0) { $0 + $1.count }
        if abs(difference) < 0.5 {
            return "Across \(totals) entries in \(withData.count) weeks with data, mean intensity is roughly level."
        }
        if difference < 0 {
            return "Across \(totals) entries in \(withData.count) weeks with data, recent weeks average \(TEFormat.decimal(abs(difference))) lower than earlier ones."
        }
        return "Across \(totals) entries in \(withData.count) weeks with data, recent weeks average \(TEFormat.decimal(difference)) higher than earlier ones."
    }

    // MARK: - Rankings

    private var triggerSection: some View {
        Group {
            let ranked = Array(TEAnalytics.triggerRanking(episodes).prefix(10))
            TESectionHeader(title: "Worst triggers", note: "by mean intensity")
            if ranked.isEmpty {
                TENotEnoughData(needed: TEAnalytics.minimumSamples, have: episodes.count)
            } else {
                TECard {
                    ForEach(ranked) { item in
                        TEBarRow(label: item.label,
                                 value: item.mean,
                                 maxValue: 10,
                                 caption: item.confident
                                    ? "mean \(TEFormat.decimal(item.mean)) of 10 · \(item.count) entries"
                                    : "\(item.count) \(item.count == 1 ? "entry" : "entries") — not enough for a firm figure",
                                 tint: TEPalette.intensity(Int(item.mean.rounded())))
                    }
                }
            }
        }
    }

    private var classSection: some View {
        Group {
            let ranked = TEAnalytics.classRanking(episodes)
            if !ranked.isEmpty {
                TESectionHeader(title: "By class")
                TECard {
                    TEBarChart(values: ranked.map { $0.mean },
                               labels: ranked.map { $0.label },
                               counts: ranked.map { $0.count },
                               maxValue: 10,
                               height: 110,
                               intensityTinted: true)
                    TEFootnote(text: ranked.map { "\($0.label) \($0.count)" }.joined(separator: " · "))
                }
            }
        }
    }

    private var contextSection: some View {
        Group {
            let ranked = Array(TEAnalytics.placeRanking(episodes).prefix(8))
            TESectionHeader(title: "Worst contexts", note: "places you named")
            if ranked.isEmpty {
                TEFootnote(text: "No places recorded yet. Adding a place to an entry takes one tap once you have logged it once.")
            } else {
                TECard {
                    ForEach(ranked) { item in
                        TEBarRow(label: item.label,
                                 value: item.mean,
                                 maxValue: 10,
                                 caption: "mean \(TEFormat.decimal(item.mean)) · \(item.count) \(item.count == 1 ? "entry" : "entries")\(item.confident ? "" : " — still thin")",
                                 tint: TEPalette.clay)
                    }
                }
            }
        }
    }

    private var roleSection: some View {
        Group {
            let ranked = TEAnalytics.roleRanking(episodes).filter { $0.key != TEPersonRole.unknown.rawValue }
            if !ranked.isEmpty {
                TESectionHeader(title: "Who was there")
                TECard {
                    ForEach(ranked) { item in
                        TEBarRow(label: item.label,
                                 value: item.mean,
                                 maxValue: 10,
                                 caption: "mean \(TEFormat.decimal(item.mean)) · \(item.count) \(item.count == 1 ? "entry" : "entries")",
                                 tint: TEPalette.mossDeep)
                    }
                    TEFootnote(text: "It is extremely common for the people closest to you to be the hardest. That is a pattern, not a statement about the relationship.")
                }
            }
        }
    }

    private var timeSection: some View {
        Group {
            TESectionHeader(title: "Time of day")
            TECard {
                HStack(alignment: .center, spacing: 14) {
                    TEDayClock(slices: TEAnalytics.hourDistribution(episodes),
                               size: TEMetrics.isNarrow ? 132 : 152)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(TEAnalytics.partOfDay(episodes)) { part in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(part.label)
                                    .font(TEType.medium(12.5))
                                    .foregroundColor(TEPalette.ink)
                                Text("\(part.count) · mean \(TEFormat.decimal(part.mean))")
                                    .font(TEType.body(11))
                                    .foregroundColor(TEPalette.inkFaint)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                TEFootnote(text: "Spoke length is how many entries fall in that hour; color is the mean intensity for the hour.")
            }
        }
    }

    private var responseSection: some View {
        Group {
            let usage = TEAnalytics.responseUsage(episodes)
            TESectionHeader(title: "What you do", note: "share of entries")
            if usage.isEmpty {
                TENotEnoughData(needed: TEAnalytics.minimumSamples, have: episodes.count)
            } else {
                TECard {
                    ForEach(usage) { item in
                        TEBarRow(label: item.label,
                                 value: item.mean,
                                 maxValue: 100,
                                 caption: "\(item.count) \(item.count == 1 ? "entry" : "entries")",
                                 tint: TEPalette.moss,
                                 valueText: "\(Int(item.mean.rounded()))%")
                    }
                }
            }
        }
    }

    private var physicalSection: some View {
        Group {
            let ranked = TEAnalytics.physicalRanking(episodes)
            if !ranked.isEmpty {
                TESectionHeader(title: "Where it lands in your body")
                TECard {
                    ForEach(ranked) { item in
                        TEBarRow(label: item.label,
                                 value: Double(item.count),
                                 maxValue: Double(max(1, ranked.map { $0.count }.max() ?? 1)),
                                 caption: "\(item.count) \(item.count == 1 ? "entry" : "entries") · mean intensity \(TEFormat.decimal(item.mean))",
                                 tint: TEPalette.rust,
                                 valueText: "\(item.count)")
                    }
                }
            }
        }
    }

    private var recoverySection: some View {
        Group {
            let weeks = TEAnalytics.weeklyRecovery(episodes, weeks: 8)
            let maxRecovery = max(10, weeks.map { $0.mean }.max() ?? 10)
            TESectionHeader(title: "Recovery time", note: "minutes, last 8 weeks")
            TECard {
                TEBarChart(values: weeks.map { $0.mean },
                           labels: weeks.map { shortWeekLabel($0.label) },
                           counts: weeks.map { $0.count },
                           maxValue: maxRecovery,
                           height: 110,
                           tint: TEPalette.clayDeep)
                if let best = TEAnalytics.shortestRecoveryResponse(episodes) {
                    Text("Of the responses with at least \(TEAnalytics.minimumSamples) entries, \"\(best.label.lowercased())\" is followed by the shortest recovery — about \(Int(best.mean.rounded())) minutes across \(best.count) entries.")
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    TEFootnote(text: "No response has \(TEAnalytics.minimumSamples) entries yet, so the app is not going to tell you which one settles fastest.")
                }
                TEFootnote(text: "This is an association in your own log, not a recommendation. A response you only use on the worst days will look worse than it is.")
            }
        }
    }
}
