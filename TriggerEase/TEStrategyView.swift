import SwiftUI

/// What the app has learned about this particular user from their own scored runs.
struct TEStrategyView: View {
    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        TEPage(title: "What works for you",
               subtitle: "Built only from runs you have scored. Nothing here is generic advice.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            if store.totalRuns == 0 {
                TEEmptyState(glyph: .chart,
                             title: "Nothing scored yet",
                             message: "Score a plan after the situation and the ranking starts here. Each technique, seating option and masking preset gets a mean rating with its sample count.\n\nBelow three samples the app says \"still learning\" instead of showing a number.")
            } else {
                summaryCard
                techniqueSection
                seatingSection
                maskingSection
                situationSection
                TEFootnote(text: "Means are unweighted. A single very good or very bad run moves a small sample a long way, which is exactly why the sample count is printed next to every figure.")
            }
        }
    }

    private var summaryCard: some View {
        TECard {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(store.totalRuns)")
                        .font(TEType.display(30))
                        .foregroundColor(TEPalette.ink)
                    Text(store.totalRuns == 1 ? "scored run" : "scored runs")
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkFaint)
                }
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(store.plans.count)")
                        .font(TEType.display(30))
                        .foregroundColor(TEPalette.ink)
                    Text(store.plans.count == 1 ? "plan" : "plans")
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkFaint)
                }
                Spacer(minLength: 0)
                if let mean = overallDifficulty {
                    TEDial(value: mean, maxValue: 10, caption: "mean\ndifficulty", size: 74, tint: TEPalette.clay)
                }
            }
        }
    }

    private var overallDifficulty: Double? {
        teMean(store.plans.flatMap { $0.runs }.map { Double($0.difficulty) })
    }

    private var techniqueSection: some View {
        Group {
            let ranked = TEPlanEngine.techniqueRanking(plans: store.plans)
            TESectionHeader(title: "Techniques", note: "\(ranked.count) used")
            if ranked.isEmpty {
                TEFootnote(text: "No technique has been marked as used in a scored run yet.")
            } else {
                TECard {
                    ForEach(ranked) { item in
                        TEBarRow(label: item.label,
                                 value: item.confident ? item.meanHelped : 0,
                                 maxValue: 10,
                                 caption: item.confident
                                    ? "mean helped \(TEFormat.decimal(item.meanHelped)) of 10 · \(item.samples) uses"
                                    : "still learning · \(item.samples) of \(TEPlanEngine.minimumSamples) uses",
                                 tint: item.confident ? TEPalette.moss : TEPalette.sandDeep,
                                 valueText: item.confident ? nil : "—")
                    }
                }
            }
        }
    }

    private var seatingSection: some View {
        Group {
            let ranked = TEPlanEngine.seatingRanking(plans: store.plans)
            TESectionHeader(title: "Seating and position", note: "\(ranked.count) rated")
            if ranked.isEmpty {
                TEFootnote(text: "Rate the position when you score a run and it appears here.")
            } else {
                TECard {
                    ForEach(ranked) { item in
                        TEBarRow(label: item.label,
                                 value: item.confident ? item.meanHelped : 0,
                                 maxValue: 10,
                                 caption: item.confident
                                    ? "mean helped \(TEFormat.decimal(item.meanHelped)) of 10 · \(item.samples) runs"
                                    : "still learning · \(item.samples) of \(TEPlanEngine.minimumSamples) runs",
                                 tint: item.confident ? TEPalette.clay : TEPalette.sandDeep,
                                 valueText: item.confident ? nil : "—")
                    }
                }
            }
        }
    }

    private var maskingSection: some View {
        Group {
            let ranked = TEPlanEngine.maskingRanking(plans: store.plans)
            TESectionHeader(title: "Masking presets", note: "\(ranked.count) rated")
            if ranked.isEmpty {
                TEFootnote(text: "Rate the masking when you score a run and it appears here.")
            } else {
                TECard {
                    ForEach(ranked) { item in
                        TEBarRow(label: item.label,
                                 value: item.confident ? item.meanHelped : 0,
                                 maxValue: 10,
                                 caption: item.confident
                                    ? "mean helped \(TEFormat.decimal(item.meanHelped)) of 10 · \(item.samples) runs"
                                    : "still learning · \(item.samples) of \(TEPlanEngine.minimumSamples) runs",
                                 tint: item.confident ? TEPalette.mossDeep : TEPalette.sandDeep,
                                 valueText: item.confident ? nil : "—")
                    }
                }
            }
        }
    }

    private var situationSection: some View {
        Group {
            let summaries = TEPlanEngine.situationSummaries(plans: store.plans)
            if !summaries.isEmpty {
                TESectionHeader(title: "Hardest situations", note: "\(summaries.count)")
                TECard {
                    ForEach(summaries) { item in
                        TEBarRow(label: item.label,
                                 value: item.meanDifficulty,
                                 maxValue: 10,
                                 caption: "\(item.samples) \(item.samples == 1 ? "run" : "runs") · left \(Int((item.leaveRate * 100).rounded()))% of the time",
                                 tint: TEPalette.intensity(Int(item.meanDifficulty.rounded())))
                    }
                }
            }
        }
    }
}
