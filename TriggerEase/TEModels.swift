import Foundation

// All saved structures decode field-by-field with `decodeIfPresent`, so adding a field in a
// future version can never wipe somebody's saved history.

// MARK: - Catalogue types (authored, never persisted)

enum TETriggerClass: String, CaseIterable, Codable {
    case oral
    case nasal
    case motion
    case environmental
    case vocal
    case visual

    var title: String {
        switch self {
        case .oral: return "Oral"
        case .nasal: return "Nasal and throat"
        case .motion: return "Repetitive motion"
        case .environmental: return "Environmental"
        case .vocal: return "Vocal"
        case .visual: return "Visual (misokinesia)"
        }
    }

    var shortTitle: String {
        switch self {
        case .oral: return "Oral"
        case .nasal: return "Nasal"
        case .motion: return "Motion"
        case .environmental: return "Environment"
        case .vocal: return "Vocal"
        case .visual: return "Visual"
        }
    }

    var blurb: String {
        switch self {
        case .oral:
            return "Sounds made by somebody else's mouth while eating or drinking. The most commonly reported class, and often the hardest to escape at a shared table."
        case .nasal:
            return "Breathing, sniffing, throat clearing. These carry further than people expect and repeat on a rhythm you cannot predict."
        case .motion:
            return "Small percussive habits — clicking, tapping, drumming. Usually unconscious on the other person's part, which is part of what makes them hard to raise."
        case .environmental:
            return "Sound from the room, the building or the street rather than from a person. Nobody to ask, so the response is usually positioning or masking."
        case .vocal:
            return "Voice sounds that are not speech directed at you — humming, whistling, a leaking headphone, a repeated verbal tic."
        case .visual:
            return "Repetitive movement seen rather than heard. Often called misokinesia. It is real, it is frequently reported alongside sound triggers, and it is almost always left out of trigger lists."
        }
    }
}

struct TETrigger: Identifiable, Hashable {
    let id: String
    let name: String
    let triggerClass: TETriggerClass
    let detail: String
}

enum TETechniqueGroup: String, CaseIterable, Codable {
    case inTheMoment
    case body
    case attention
    case thinking
    case environment
    case communication
    case afterwards
    case preparation

    var title: String {
        switch self {
        case .inTheMoment: return "In the moment"
        case .body: return "Body and breath"
        case .attention: return "Attention"
        case .thinking: return "Thinking it through"
        case .environment: return "Room and position"
        case .communication: return "What to say"
        case .afterwards: return "Afterwards"
        case .preparation: return "Before it starts"
        }
    }
}

struct TETechnique: Identifiable, Hashable {
    let id: String
    let title: String
    let group: TETechniqueGroup
    let whenToUse: String
    let steps: [String]
    /// Scripts are shown in large type so they can be read on screen while talking to someone.
    let isScript: Bool
}

struct TESituationTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let blurb: String
    let seatingOptions: [String]
    let exitLines: [String]
    let suggestedTechniqueIDs: [String]
    let likelyTriggerIDs: [String]
    let suggestedMasking: String
}

struct TELearnCard: Identifiable, Hashable {
    let id: String
    let title: String
    let section: String
    let paragraphs: [String]
}

// MARK: - Persisted records

struct TETechniqueOutcome: Codable, Identifiable, Hashable {
    var id: String { techniqueID }
    var techniqueID: String
    var used: Bool
    /// 0...10, only meaningful when `used` is true.
    var helped: Int

    init(techniqueID: String, used: Bool = false, helped: Int = 5) {
        self.techniqueID = techniqueID
        self.used = used
        self.helped = helped
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        techniqueID = c.teValue(String.self, .techniqueID, "")
        used = c.teValue(Bool.self, .used, false)
        helped = c.teValue(Int.self, .helped, 5)
    }

    enum CodingKeys: String, CodingKey { case techniqueID, used, helped }
}

struct TEPlanRun: Codable, Identifiable, Hashable {
    var id: UUID
    var date: Date
    /// 0 = easy, 10 = as hard as it gets.
    var difficulty: Int
    var neededToLeave: Bool
    var outcomes: [TETechniqueOutcome]
    /// -1 means "not rated".
    var seatingHelped: Int
    var maskingHelped: Int
    var note: String

    init(id: UUID = UUID(), date: Date = Date(), difficulty: Int = 5, neededToLeave: Bool = false,
         outcomes: [TETechniqueOutcome] = [], seatingHelped: Int = -1, maskingHelped: Int = -1,
         note: String = "") {
        self.id = id
        self.date = date
        self.difficulty = difficulty
        self.neededToLeave = neededToLeave
        self.outcomes = outcomes
        self.seatingHelped = seatingHelped
        self.maskingHelped = maskingHelped
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.teValue(UUID.self, .id, UUID())
        date = c.teValue(Date.self, .date, Date())
        difficulty = c.teValue(Int.self, .difficulty, 5)
        neededToLeave = c.teValue(Bool.self, .neededToLeave, false)
        outcomes = c.teValue([TETechniqueOutcome].self, .outcomes, [])
        seatingHelped = c.teValue(Int.self, .seatingHelped, -1)
        maskingHelped = c.teValue(Int.self, .maskingHelped, -1)
        note = c.teValue(String.self, .note, "")
    }

    enum CodingKeys: String, CodingKey {
        case id, date, difficulty, neededToLeave, outcomes, seatingHelped, maskingHelped, note
    }
}

struct TEPlan: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var templateID: String
    var scheduledAt: Date
    var expectedTriggerIDs: [String]
    var seatingOption: String
    var maskingPreset: String
    var techniqueIDs: [String]
    var exitLine: String
    var supportPerson: String
    var note: String
    var createdAt: Date
    var runs: [TEPlanRun]

    init(id: UUID = UUID(), name: String = "", templateID: String = "", scheduledAt: Date = Date(),
         expectedTriggerIDs: [String] = [], seatingOption: String = "", maskingPreset: String = TEMaskPreset.none.rawValue,
         techniqueIDs: [String] = [], exitLine: String = "", supportPerson: String = "",
         note: String = "", createdAt: Date = Date(), runs: [TEPlanRun] = []) {
        self.id = id
        self.name = name
        self.templateID = templateID
        self.scheduledAt = scheduledAt
        self.expectedTriggerIDs = expectedTriggerIDs
        self.seatingOption = seatingOption
        self.maskingPreset = maskingPreset
        self.techniqueIDs = techniqueIDs
        self.exitLine = exitLine
        self.supportPerson = supportPerson
        self.note = note
        self.createdAt = createdAt
        self.runs = runs
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.teValue(UUID.self, .id, UUID())
        name = c.teValue(String.self, .name, "Plan")
        templateID = c.teValue(String.self, .templateID, "")
        scheduledAt = c.teValue(Date.self, .scheduledAt, Date())
        expectedTriggerIDs = c.teValue([String].self, .expectedTriggerIDs, [])
        seatingOption = c.teValue(String.self, .seatingOption, "")
        maskingPreset = c.teValue(String.self, .maskingPreset, TEMaskPreset.none.rawValue)
        techniqueIDs = c.teValue([String].self, .techniqueIDs, [])
        exitLine = c.teValue(String.self, .exitLine, "")
        supportPerson = c.teValue(String.self, .supportPerson, "")
        note = c.teValue(String.self, .note, "")
        createdAt = c.teValue(Date.self, .createdAt, Date())
        runs = c.teValue([TEPlanRun].self, .runs, [])
    }

    enum CodingKeys: String, CodingKey {
        case id, name, templateID, scheduledAt, expectedTriggerIDs, seatingOption, maskingPreset
        case techniqueIDs, exitLine, supportPerson, note, createdAt, runs
    }

    var averageDifficulty: Double? {
        teMean(runs.map { Double($0.difficulty) })
    }

    /// Change in difficulty between the first half and the second half of the repeats.
    var difficultyTrend: Double? {
        guard runs.count >= 4 else { return nil }
        let sorted = runs.sorted { $0.date < $1.date }
        let half = sorted.count / 2
        let early = teMean(sorted.prefix(half).map { Double($0.difficulty) })
        let late = teMean(sorted.suffix(sorted.count - half).map { Double($0.difficulty) })
        guard let e = early, let l = late else { return nil }
        return l - e
    }
}

enum TEPersonRole: String, CaseIterable, Codable {
    case family, partner, colleague, stranger, friend, child, housemate, myself, unknown

    var title: String {
        switch self {
        case .family: return "Family"
        case .partner: return "Partner"
        case .colleague: return "Colleague"
        case .stranger: return "Stranger"
        case .friend: return "Friend"
        case .child: return "Child"
        case .housemate: return "Housemate"
        case .myself: return "No one / myself"
        case .unknown: return "Not recorded"
        }
    }
}

enum TEResponse: String, CaseIterable, Codable {
    case endured, masked, left, asked, distracted, movedSeat, other

    var title: String {
        switch self {
        case .endured: return "Endured it"
        case .masked: return "Masked it"
        case .left: return "Left the room"
        case .asked: return "Asked them to stop"
        case .distracted: return "Distracted myself"
        case .movedSeat: return "Moved position"
        case .other: return "Something else"
        }
    }
}

enum TEPhysicalSign: String, CaseIterable, Codable {
    case jawClench, chestTightness, heat, racingHeart, shoulderTension, nausea, tears, freeze
    case skinCrawl, breathHold, handClench, stomachDrop

    var title: String {
        switch self {
        case .jawClench: return "Jaw clench"
        case .chestTightness: return "Chest tightness"
        case .heat: return "Heat / flush"
        case .racingHeart: return "Racing heart"
        case .shoulderTension: return "Shoulder tension"
        case .nausea: return "Nausea"
        case .tears: return "Tears"
        case .freeze: return "Freeze"
        case .skinCrawl: return "Skin crawling"
        case .breathHold: return "Holding my breath"
        case .handClench: return "Hands clenched"
        case .stomachDrop: return "Stomach drop"
        }
    }
}

struct TEEpisode: Codable, Identifiable, Hashable {
    var id: UUID
    var date: Date
    var triggerID: String
    var role: TEPersonRole
    var place: String
    var intensity: Int
    var physical: [TEPhysicalSign]
    var response: TEResponse
    var durationMinutes: Int
    var recoveryMinutes: Int
    var note: String

    init(id: UUID = UUID(), date: Date = Date(), triggerID: String = "", role: TEPersonRole = .unknown,
         place: String = "", intensity: Int = 5, physical: [TEPhysicalSign] = [],
         response: TEResponse = .endured, durationMinutes: Int = 5, recoveryMinutes: Int = 10,
         note: String = "") {
        self.id = id
        self.date = date
        self.triggerID = triggerID
        self.role = role
        self.place = place
        self.intensity = intensity
        self.physical = physical
        self.response = response
        self.durationMinutes = durationMinutes
        self.recoveryMinutes = recoveryMinutes
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.teValue(UUID.self, .id, UUID())
        date = c.teValue(Date.self, .date, Date())
        triggerID = c.teValue(String.self, .triggerID, "")
        role = c.teValue(TEPersonRole.self, .role, .unknown)
        place = c.teValue(String.self, .place, "")
        intensity = c.teValue(Int.self, .intensity, 5)
        physical = c.teValue([TEPhysicalSign].self, .physical, [])
        response = c.teValue(TEResponse.self, .response, .endured)
        durationMinutes = c.teValue(Int.self, .durationMinutes, 5)
        recoveryMinutes = c.teValue(Int.self, .recoveryMinutes, 10)
        note = c.teValue(String.self, .note, "")
    }

    enum CodingKeys: String, CodingKey {
        case id, date, triggerID, role, place, intensity, physical, response
        case durationMinutes, recoveryMinutes, note
    }
}

struct TELadderStepRecord: Codable, Identifiable, Hashable {
    var id: UUID
    var triggerID: String
    var stepIndex: Int
    var date: Date
    var distressBefore: Int
    var distressAfter: Int
    var stoppedEarly: Bool
    var note: String

    init(id: UUID = UUID(), triggerID: String = "", stepIndex: Int = 0, date: Date = Date(),
         distressBefore: Int = 5, distressAfter: Int = 5, stoppedEarly: Bool = false, note: String = "") {
        self.id = id
        self.triggerID = triggerID
        self.stepIndex = stepIndex
        self.date = date
        self.distressBefore = distressBefore
        self.distressAfter = distressAfter
        self.stoppedEarly = stoppedEarly
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.teValue(UUID.self, .id, UUID())
        triggerID = c.teValue(String.self, .triggerID, "")
        stepIndex = c.teValue(Int.self, .stepIndex, 0)
        date = c.teValue(Date.self, .date, Date())
        distressBefore = c.teValue(Int.self, .distressBefore, 5)
        distressAfter = c.teValue(Int.self, .distressAfter, 5)
        stoppedEarly = c.teValue(Bool.self, .stoppedEarly, false)
        note = c.teValue(String.self, .note, "")
    }

    enum CodingKeys: String, CodingKey {
        case id, triggerID, stepIndex, date, distressBefore, distressAfter, stoppedEarly, note
    }
}

struct TEPreferences: Codable {
    var hasSeenOnboarding: Bool
    var hasSeenVolumeWarning: Bool
    var defaultMasking: String
    var sleepTimerMinutes: Int
    var breathInSeconds: Double
    var breathHoldSeconds: Double
    var breathOutSeconds: Double
    var masterLevel: Double
    var privacyLockEnabled: Bool
    var ladderOptIn: Bool

    init() {
        hasSeenOnboarding = false
        hasSeenVolumeWarning = false
        defaultMasking = TEMaskPreset.brown.rawValue
        sleepTimerMinutes = 20
        breathInSeconds = 4
        breathHoldSeconds = 2
        breathOutSeconds = 6
        masterLevel = 0.35
        privacyLockEnabled = false
        ladderOptIn = false
    }

    init(from decoder: Decoder) throws {
        self.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hasSeenOnboarding = c.teValue(Bool.self, .hasSeenOnboarding, false)
        hasSeenVolumeWarning = c.teValue(Bool.self, .hasSeenVolumeWarning, false)
        defaultMasking = c.teValue(String.self, .defaultMasking, TEMaskPreset.brown.rawValue)
        sleepTimerMinutes = c.teValue(Int.self, .sleepTimerMinutes, 20)
        breathInSeconds = c.teValue(Double.self, .breathInSeconds, 4)
        breathHoldSeconds = c.teValue(Double.self, .breathHoldSeconds, 2)
        breathOutSeconds = c.teValue(Double.self, .breathOutSeconds, 6)
        masterLevel = c.teValue(Double.self, .masterLevel, 0.35)
        privacyLockEnabled = c.teValue(Bool.self, .privacyLockEnabled, false)
        ladderOptIn = c.teValue(Bool.self, .ladderOptIn, false)
    }

    enum CodingKeys: String, CodingKey {
        case hasSeenOnboarding, hasSeenVolumeWarning, defaultMasking, sleepTimerMinutes
        case breathInSeconds, breathHoldSeconds, breathOutSeconds, masterLevel
        case privacyLockEnabled, ladderOptIn
    }
}

struct TEArchive: Codable {
    var plans: [TEPlan]
    var episodes: [TEEpisode]
    var triggerRatings: [String: Int]
    var favouriteTechniqueIDs: [String]
    var ladderRecords: [TELadderStepRecord]
    var preferences: TEPreferences
    var readLearnCardIDs: [String]

    init() {
        plans = []
        episodes = []
        triggerRatings = [:]
        favouriteTechniqueIDs = []
        ladderRecords = []
        preferences = TEPreferences()
        readLearnCardIDs = []
    }

    init(from decoder: Decoder) throws {
        self.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        plans = c.teValue([TEPlan].self, .plans, [])
        episodes = c.teValue([TEEpisode].self, .episodes, [])
        triggerRatings = c.teValue([String: Int].self, .triggerRatings, [:])
        favouriteTechniqueIDs = c.teValue([String].self, .favouriteTechniqueIDs, [])
        ladderRecords = c.teValue([TELadderStepRecord].self, .ladderRecords, [])
        preferences = c.teValue(TEPreferences.self, .preferences, TEPreferences())
        readLearnCardIDs = c.teValue([String].self, .readLearnCardIDs, [])
    }

    enum CodingKeys: String, CodingKey {
        case plans, episodes, triggerRatings, favouriteTechniqueIDs, ladderRecords, preferences, readLearnCardIDs
    }
}

// MARK: - Forgiving decode helper

extension KeyedDecodingContainer {
    /// Reads a key, falling back to a default when the key is absent, null or malformed.
    /// Every persisted struct decodes through this, so a new field added in a later version
    /// can never throw and wipe the user's saved history.
    func teValue<T: Decodable>(_ type: T.Type, _ key: Key, _ fallback: T) -> T {
        // `try?` flattens the nested optional here, so a missing key, an explicit null and a
        // malformed value all arrive as nil and all fall back to the default.
        if let value = try? decodeIfPresent(type, forKey: key) { return value }
        return fallback
    }
}
