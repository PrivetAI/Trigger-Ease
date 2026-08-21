import Foundation

/// Turns scored plan runs into a ranking of what actually works for this user.
/// Below `minimumSamples` nothing is presented as a number — the app says "still learning"
/// rather than pretending three data points are a finding.
enum TEPlanEngine {

    static let minimumSamples = 3

    struct Ranked: Identifiable, Hashable {
        var id: String { key }
        let key: String
        let label: String
        let meanHelped: Double
        let samples: Int
        let confident: Bool

        var displayScore: String {
            confident ? TEFormat.decimal(meanHelped) : "still learning"
        }
    }

    // MARK: - Technique ranking

    static func techniqueRanking(plans: [TEPlan]) -> [Ranked] {
        var buckets: [String: [Double]] = [:]
        for plan in plans {
            for run in plan.runs {
                for outcome in run.outcomes where outcome.used {
                    buckets[outcome.techniqueID, default: []].append(Double(max(0, min(10, outcome.helped))))
                }
            }
        }
        return buckets.compactMap { key, values -> Ranked? in
            guard let technique = TETechniqueCatalog.byID(key) else { return nil }
            guard let mean = teMean(values) else { return nil }
            return Ranked(key: key, label: technique.title, meanHelped: mean,
                          samples: values.count, confident: values.count >= minimumSamples)
        }
        .sorted(by: rankSort)
    }

    // MARK: - Seating ranking

    static func seatingRanking(plans: [TEPlan]) -> [Ranked] {
        var buckets: [String: [Double]] = [:]
        for plan in plans {
            let option = plan.seatingOption.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !option.isEmpty else { continue }
            for run in plan.runs where run.seatingHelped >= 0 {
                buckets[option, default: []].append(Double(min(10, run.seatingHelped)))
            }
        }
        return buckets.compactMap { key, values -> Ranked? in
            guard let mean = teMean(values) else { return nil }
            return Ranked(key: key, label: key, meanHelped: mean,
                          samples: values.count, confident: values.count >= minimumSamples)
        }
        .sorted(by: rankSort)
    }

    // MARK: - Masking ranking

    static func maskingRanking(plans: [TEPlan]) -> [Ranked] {
        var buckets: [String: [Double]] = [:]
        for plan in plans {
            let preset = plan.maskingPreset
            guard preset != TEMaskPreset.none.rawValue else { continue }
            for run in plan.runs where run.maskingHelped >= 0 {
                buckets[preset, default: []].append(Double(min(10, run.maskingHelped)))
            }
        }
        return buckets.compactMap { key, values -> Ranked? in
            guard let mean = teMean(values) else { return nil }
            let label = TEMaskPreset(rawValue: key)?.title ?? key
            return Ranked(key: key, label: label, meanHelped: mean,
                          samples: values.count, confident: values.count >= minimumSamples)
        }
        .sorted(by: rankSort)
    }

    private static func rankSort(_ lhs: Ranked, _ rhs: Ranked) -> Bool {
        if lhs.confident != rhs.confident { return lhs.confident }
        if abs(lhs.meanHelped - rhs.meanHelped) > 0.001 { return lhs.meanHelped > rhs.meanHelped }
        return lhs.samples > rhs.samples
    }

    // MARK: - Situation difficulty

    struct SituationSummary: Identifiable, Hashable {
        var id: String { templateID }
        let templateID: String
        let label: String
        let meanDifficulty: Double
        let samples: Int
        let leaveRate: Double
    }

    static func situationSummaries(plans: [TEPlan]) -> [SituationSummary] {
        var difficulty: [String: [Double]] = [:]
        var leaves: [String: [Double]] = [:]
        for plan in plans {
            let key = plan.templateID.isEmpty ? "blank" : plan.templateID
            for run in plan.runs {
                difficulty[key, default: []].append(Double(max(0, min(10, run.difficulty))))
                leaves[key, default: []].append(run.neededToLeave ? 1 : 0)
            }
        }
        return difficulty.compactMap { key, values -> SituationSummary? in
            guard let mean = teMean(values) else { return nil }
            let label = TESituationTemplates.byID(key)?.name ?? TESituationTemplates.blank.name
            let leaveRate = teMean(leaves[key] ?? []) ?? 0
            return SituationSummary(templateID: key, label: label, meanDifficulty: mean,
                                    samples: values.count, leaveRate: leaveRate)
        }
        .sorted { lhs, rhs in
            if abs(lhs.meanDifficulty - rhs.meanDifficulty) > 0.001 { return lhs.meanDifficulty > rhs.meanDifficulty }
            return lhs.samples > rhs.samples
        }
    }

    // MARK: - Best techniques against one specific trigger

    /// Techniques used in plans that expected this trigger, ranked by how much they helped.
    static func techniquesFor(triggerID: String, plans: [TEPlan]) -> [Ranked] {
        var buckets: [String: [Double]] = [:]
        for plan in plans where plan.expectedTriggerIDs.contains(triggerID) {
            for run in plan.runs {
                for outcome in run.outcomes where outcome.used {
                    buckets[outcome.techniqueID, default: []].append(Double(max(0, min(10, outcome.helped))))
                }
            }
        }
        return buckets.compactMap { key, values -> Ranked? in
            guard let technique = TETechniqueCatalog.byID(key), let mean = teMean(values) else { return nil }
            return Ranked(key: key, label: technique.title, meanHelped: mean,
                          samples: values.count, confident: values.count >= minimumSamples)
        }
        .sorted(by: rankSort)
    }

    // MARK: - Suggestions

    /// The two techniques the app offers first when a plan is created from a template:
    /// the user's own best-scoring cards where enough data exists, otherwise the authored pair.
    static func suggestedTechniques(for template: TESituationTemplate, plans: [TEPlan]) -> [String] {
        let ranked = techniqueRanking(plans: plans).filter { $0.confident && $0.meanHelped >= 5 }
        var picks: [String] = []
        for candidate in ranked where template.suggestedTechniqueIDs.contains(candidate.key) {
            if picks.count < 2 { picks.append(candidate.key) }
        }
        for id in template.suggestedTechniqueIDs where !picks.contains(id) {
            if picks.count < 2 { picks.append(id) }
        }
        for candidate in ranked where !picks.contains(candidate.key) {
            if picks.count < 2 { picks.append(candidate.key) }
        }
        return Array(picks.prefix(2))
    }

    /// A short, plain sentence about a repeated plan's trend. Never congratulatory.
    static func trendSentence(for plan: TEPlan) -> String {
        guard plan.runs.count >= 2 else {
            return plan.runs.count == 1 ? "Scored once so far." : "Not scored yet."
        }
        guard let trend = plan.difficultyTrend else {
            let mean = plan.averageDifficulty.map { TEFormat.decimal($0) } ?? "—"
            return "\(plan.runs.count) repeats, average difficulty \(mean)."
        }
        let mean = plan.averageDifficulty.map { TEFormat.decimal($0) } ?? "—"
        if trend <= -0.75 {
            return "\(plan.runs.count) repeats, average \(mean). Later repeats have been rated easier than earlier ones."
        }
        if trend >= 0.75 {
            return "\(plan.runs.count) repeats, average \(mean). Later repeats have been rated harder than earlier ones."
        }
        return "\(plan.runs.count) repeats, average \(mean). Roughly level across repeats."
    }
}
