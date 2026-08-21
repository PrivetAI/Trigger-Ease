import Foundation
import Combine

/// Single owner of everything the user has entered. All state is value types so SwiftUI
/// redraws correctly when an inner field changes.
final class TEStore: ObservableObject {

    @Published private(set) var plans: [TEPlan] = []
    @Published private(set) var episodes: [TEEpisode] = []
    @Published private(set) var triggerRatings: [String: Int] = [:]
    @Published private(set) var favouriteTechniqueIDs: [String] = []
    @Published private(set) var ladderRecords: [TELadderStepRecord] = []
    @Published private(set) var readLearnCardIDs: [String] = []
    @Published var preferences = TEPreferences() {
        didSet { scheduleSave() }
    }

    private let fileName = "trigger-ease-archive.json"
    private var saveWorkItem: DispatchWorkItem?

    init() {
        load()
    }

    // MARK: - Persistence

    private var storageURL: URL? {
        guard let base = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: true) else { return nil }
        let folder = base.appendingPathComponent("TriggerEase", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent(fileName)
    }

    private func load() {
        guard let url = storageURL, let data = try? Data(contentsOf: url) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let archive = try? decoder.decode(TEArchive.self, from: data) else {
            // The next save would write an empty archive straight over the file. Move it aside
            // first so whatever is in there is at least recoverable.
            quarantineArchive(at: url)
            return
        }
        plans = archive.plans
        episodes = archive.episodes
        triggerRatings = archive.triggerRatings
        favouriteTechniqueIDs = archive.favouriteTechniqueIDs
        ladderRecords = archive.ladderRecords
        readLearnCardIDs = archive.readLearnCardIDs
        preferences = archive.preferences
    }

    /// Renames an undecodable archive to a `.corrupt` sibling, keeping any previous one.
    private func quarantineArchive(at url: URL) {
        let manager = FileManager.default
        var target = url.appendingPathExtension("corrupt")
        var suffix = 2
        while manager.fileExists(atPath: target.path) && suffix < 50 {
            target = url.appendingPathExtension("corrupt-\(suffix)")
            suffix += 1
        }
        try? manager.moveItem(at: url, to: target)
    }

    private func scheduleSave() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in self?.saveNow() }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: item)
    }

    func saveNow() {
        guard let url = storageURL else { return }
        var archive = TEArchive()
        archive.plans = plans
        archive.episodes = episodes
        archive.triggerRatings = triggerRatings
        archive.favouriteTechniqueIDs = favouriteTechniqueIDs
        archive.ladderRecords = ladderRecords
        archive.readLearnCardIDs = readLearnCardIDs
        archive.preferences = preferences
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        guard let data = try? encoder.encode(archive) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Plans

    func addPlan(_ plan: TEPlan) {
        plans.append(plan)
        scheduleSave()
    }

    func updatePlan(_ plan: TEPlan) {
        guard let index = plans.firstIndex(where: { $0.id == plan.id }) else { return }
        plans[index] = plan
        scheduleSave()
    }

    func deletePlan(id: UUID) {
        plans.removeAll { $0.id == id }
        scheduleSave()
    }

    func plan(id: UUID) -> TEPlan? {
        plans.first { $0.id == id }
    }

    func addRun(_ run: TEPlanRun, toPlanID planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        plans[index].runs.append(run)
        scheduleSave()
    }

    func updateRun(_ run: TEPlanRun, inPlanID planID: UUID) {
        guard let planIndex = plans.firstIndex(where: { $0.id == planID }),
              let runIndex = plans[planIndex].runs.firstIndex(where: { $0.id == run.id }) else { return }
        plans[planIndex].runs[runIndex] = run
        scheduleSave()
    }

    func deleteRun(id: UUID, fromPlanID planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        plans[index].runs.removeAll { $0.id == id }
        scheduleSave()
    }

    var upcomingPlans: [TEPlan] {
        let now = Date()
        return plans
            .filter { $0.scheduledAt >= teStartOfDay(now) }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    var repeatablePlans: [TEPlan] {
        plans.sorted { lhs, rhs in
            if lhs.runs.count != rhs.runs.count { return lhs.runs.count > rhs.runs.count }
            return lhs.name.lowercased() < rhs.name.lowercased()
        }
    }

    var plansNeedingScore: [TEPlan] {
        let now = Date()
        return plans.filter { plan in
            guard plan.scheduledAt < now else { return false }
            // Needs a score if the newest run predates the scheduled time.
            let newest = plan.runs.map { $0.date }.max()
            guard let last = newest else { return true }
            return last < plan.scheduledAt
        }.sorted { $0.scheduledAt > $1.scheduledAt }
    }

    var totalRuns: Int { plans.reduce(0) { $0 + $1.runs.count } }

    // MARK: - Episodes

    func addEpisode(_ episode: TEEpisode) {
        episodes.append(episode)
        scheduleSave()
    }

    func updateEpisode(_ episode: TEEpisode) {
        guard let index = episodes.firstIndex(where: { $0.id == episode.id }) else { return }
        episodes[index] = episode
        scheduleSave()
    }

    func deleteEpisode(id: UUID) {
        episodes.removeAll { $0.id == id }
        scheduleSave()
    }

    var episodesNewestFirst: [TEEpisode] {
        episodes.sorted { $0.date > $1.date }
    }

    // MARK: - Trigger profile

    func rating(for triggerID: String) -> Int? {
        triggerRatings[triggerID]
    }

    func setRating(_ value: Int?, for triggerID: String) {
        if let value = value {
            triggerRatings[triggerID] = max(0, min(10, value))
        } else {
            triggerRatings.removeValue(forKey: triggerID)
        }
        scheduleSave()
    }

    var ratedTriggerCount: Int { triggerRatings.count }

    var topRatedTriggers: [(trigger: TETrigger, rating: Int)] {
        triggerRatings.compactMap { key, value -> (TETrigger, Int)? in
            guard let trigger = TETriggerCatalog.byID(key) else { return nil }
            return (trigger, value)
        }
        .sorted { lhs, rhs in
            if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
            return lhs.0.name < rhs.0.name
        }
        .map { (trigger: $0.0, rating: $0.1) }
    }

    // MARK: - Favourites

    func isFavourite(_ techniqueID: String) -> Bool {
        favouriteTechniqueIDs.contains(techniqueID)
    }

    func toggleFavourite(_ techniqueID: String) {
        if let index = favouriteTechniqueIDs.firstIndex(of: techniqueID) {
            favouriteTechniqueIDs.remove(at: index)
        } else {
            favouriteTechniqueIDs.append(techniqueID)
        }
        scheduleSave()
    }

    // MARK: - Learn

    func markLearnCardRead(_ id: String) {
        guard !readLearnCardIDs.contains(id) else { return }
        readLearnCardIDs.append(id)
        scheduleSave()
    }

    func isLearnCardRead(_ id: String) -> Bool { readLearnCardIDs.contains(id) }

    // MARK: - Ladder

    func addLadderRecord(_ record: TELadderStepRecord) {
        ladderRecords.append(record)
        scheduleSave()
    }

    func ladderRecords(for triggerID: String) -> [TELadderStepRecord] {
        ladderRecords.filter { $0.triggerID == triggerID }.sorted { $0.date < $1.date }
    }

    /// Highest step index the user has completed without stopping early, or -1 for none.
    func ladderReached(for triggerID: String) -> Int {
        ladderRecords(for: triggerID).filter { !$0.stoppedEarly }.map { $0.stepIndex }.max() ?? -1
    }

    func clearLadder(for triggerID: String) {
        ladderRecords.removeAll { $0.triggerID == triggerID }
        scheduleSave()
    }

    // MARK: - Reset

    func resetEverything() {
        plans = []
        episodes = []
        triggerRatings = [:]
        favouriteTechniqueIDs = []
        ladderRecords = []
        readLearnCardIDs = []
        var fresh = TEPreferences()
        fresh.hasSeenOnboarding = true
        preferences = fresh
        saveNow()
    }

}
