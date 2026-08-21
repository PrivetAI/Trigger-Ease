import Foundation

// Fourteen authored situation templates. Each carries its own seating options, exit lines,
// likely triggers and a starting pair of techniques, so a plan can be built in about a minute.

enum TESituationTemplates {

    static let all: [TESituationTemplate] = [
        TESituationTemplate(
            id: "familymeal",
            name: "Family meal",
            blurb: "The situation people ask about most. Everyone is close, everyone is eating, and it is the hardest place to raise anything.",
            seatingOptions: [
                "End of the table, nobody on one side",
                "Beside the main trigger rather than opposite",
                "Nearest the kitchen, so getting up looks like helping",
                "Facing away from the busiest end",
                "Next to the person who already knows",
                "Nearest the door"
            ],
            exitLines: [
                "Just going to check on something in the kitchen.",
                "Back in a minute.",
                "I'll get the next round of drinks.",
                "Going to step outside for some air.",
                "I'll start clearing — carry on."
            ],
            suggestedTechniqueIDs: ["t_seat", "t_conversation", "t_54321", "s_handsignal"],
            likelyTriggerIDs: ["chewing", "crunchy", "openmouth", "slurping", "cutleryplate", "lipsmack", "swallow"],
            suggestedMasking: TEMaskPreset.none.rawValue),

        TESituationTemplate(
            id: "restaurant",
            name: "Restaurant",
            blurb: "More background sound than home, which helps, but no control over who sits nearby.",
            seatingOptions: [
                "Corner table against a wall",
                "Booth with high sides",
                "Back to the room, facing your own party",
                "Away from the pass and the bar",
                "Outside table if the weather allows",
                "Away from the door and the till"
            ],
            exitLines: [
                "Just heading to the bathroom.",
                "I'll go and settle up.",
                "Going to take a quick call outside.",
                "Back in a moment — carry on ordering."
            ],
            suggestedTechniqueIDs: ["s_restaurant", "t_seat", "t_earplugs", "t_sightline"],
            likelyTriggerIDs: ["cutleryplate", "chewing", "slurping", "loudvoice", "icecrunch", "straw", "specificlaugh"],
            suggestedMasking: TEMaskPreset.none.rawValue),

        TESituationTemplate(
            id: "openplan",
            name: "Open-plan office",
            blurb: "Long exposure, same people, every day. Small permanent changes are worth far more here than in-the-moment coping.",
            seatingOptions: [
                "Corner desk, back to a wall",
                "Away from the walkway and the kitchen",
                "Beside soft furnishings rather than glass",
                "Furthest desk from the loudest bank",
                "Booked quiet room for focused blocks",
                "Facing a window rather than the room"
            ],
            exitLines: [
                "Just grabbing a coffee.",
                "I'm going to work from the quiet room for an hour.",
                "Stepping out for a call.",
                "Taking my lunch now."
            ],
            suggestedTechniqueIDs: ["t_office", "s_desk_move", "t_distance", "t_soundfloor"],
            likelyTriggerIDs: ["keyboard", "penclick", "sniffing", "throatclear", "mouseclick", "loudvoice", "legjiggle", "crunchy"],
            suggestedMasking: TEMaskPreset.brown.rawValue),

        TESituationTemplate(
            id: "studyspace",
            name: "Shared study space",
            blurb: "Silence makes small sounds enormous. A library is often harder than a café for exactly that reason.",
            seatingOptions: [
                "Individual carrel or booth",
                "Study room booked in advance",
                "Corner desk facing the wall",
                "Far from the entrance and the printers",
                "Café or reading room with a higher sound floor"
            ],
            exitLines: [
                "Taking a break.",
                "Moving to a different floor.",
                "Back in ten."
            ],
            suggestedTechniqueIDs: ["t_soundfloor", "t_distance", "t_earplugs", "t_timing"],
            likelyTriggerIDs: ["penclick", "keyboard", "sniffing", "papershuffle", "clock", "whispering", "foottap"],
            suggestedMasking: TEMaskPreset.brown.rawValue),

        TESituationTemplate(
            id: "cinema",
            name: "Cinema",
            blurb: "Loud on screen, silent between scenes, and food everywhere. Seat choice does nearly all the work.",
            seatingOptions: [
                "Aisle seat, one empty seat to the side",
                "Back row, nobody behind you",
                "Front section where crowds are thinner",
                "First showing of the day",
                "Midweek afternoon rather than a weekend evening"
            ],
            exitLines: [
                "Just stepping out for a second.",
                "Going to move seats.",
                "Back in a minute."
            ],
            suggestedTechniqueIDs: ["t_seat", "t_timing", "t_earplugs", "t_anchorobject"],
            likelyTriggerIDs: ["crisppacket", "wrapper", "straw", "crunchy", "whispering", "icecrunch", "phonevibrate"],
            suggestedMasking: TEMaskPreset.none.rawValue),

        TESituationTemplate(
            id: "carjourney",
            name: "Long car journey",
            blurb: "A small sealed box you cannot leave. Everything here has to be agreed before you set off.",
            seatingOptions: [
                "Driving — the task itself occupies attention",
                "Front passenger seat",
                "Rear seat diagonally opposite the trigger",
                "Window seat with the window slightly open",
                "Furthest row if it is a larger vehicle"
            ],
            exitLines: [
                "Can we stop at the next rest stop?",
                "I need five minutes when you can pull in.",
                "Mind if I put something on?"
            ],
            suggestedTechniqueIDs: ["t_car", "t_musiclyrics", "t_478", "t_scripted_exit"],
            likelyTriggerIDs: ["crunchy", "gum", "sniffing", "wrapper", "kneebounce", "singingalong", "loudbreath"],
            suggestedMasking: TEMaskPreset.rumble.rawValue),

        TESituationTemplate(
            id: "transport",
            name: "Public transport",
            blurb: "Short, crowded and unpredictable, but you can usually move — which most people forget they are allowed to do.",
            seatingOptions: [
                "Standing near a door",
                "Single seat rather than a pair",
                "Quiet carriage",
                "Moving carriage at the next stop",
                "By a window with road or track noise"
            ],
            exitLines: [
                "Excuse me — moving down.",
                "Getting off here.",
                "Sorry, just squeezing past."
            ],
            suggestedTechniqueIDs: ["t_distance", "t_earplugs", "t_musiclyrics", "t_shift"],
            likelyTriggerIDs: ["headphoneleak", "speakerphone", "sniffing", "crisppacket", "legjiggle", "phonevibrate", "cliketiquette"],
            suggestedMasking: TEMaskPreset.brown.rawValue),

        TESituationTemplate(
            id: "flight",
            name: "Flight",
            blurb: "Hours, fixed seat, no exit. The one situation where planning genuinely has to happen at booking time.",
            seatingOptions: [
                "Window seat, wall on one side",
                "Row with an empty middle if you can select it",
                "Away from the galley and the toilets",
                "Forward of the wing, where engine noise is lower",
                "Exit row for the extra distance"
            ],
            exitLines: [
                "Just going to stretch my legs.",
                "Sorry, could I get out for a moment?",
                "Going to stand at the back for a bit."
            ],
            suggestedTechniqueIDs: ["t_prepack", "t_earplugs", "t_box", "t_musiclyrics"],
            likelyTriggerIDs: ["crunchy", "wrapper", "snoring", "coughing", "kneebounce", "babbling", "loudbreath"],
            suggestedMasking: TEMaskPreset.rumble.rawValue),

        TESituationTemplate(
            id: "exam",
            name: "Classroom or exam hall",
            blurb: "Enforced silence plus a fixed seat plus a time limit. Accommodations exist and are worth asking for early.",
            seatingOptions: [
                "Front row, nobody in front of you",
                "Edge seat by the wall",
                "Separate or smaller room if arranged",
                "Away from the radiator, clock and door",
                "Back corner with the room in front of you"
            ],
            exitLines: [
                "May I step out for a moment?",
                "Could I move seats, please?",
                "I need a short break."
            ],
            suggestedTechniqueIDs: ["s_exam", "t_earplugs", "t_box", "t_rhythmoverlay"],
            likelyTriggerIDs: ["penclick", "sniffing", "coughing", "clock", "papershuffle", "foottap", "pentap"],
            suggestedMasking: TEMaskPreset.none.rawValue),

        TESituationTemplate(
            id: "waitingroom",
            name: "Waiting room",
            blurb: "Unknown length, nothing to do, and often a television nobody is watching.",
            seatingOptions: [
                "Corner seat away from the television",
                "Nearest the door",
                "Standing in the corridor if allowed",
                "Waiting outside and coming in at the time",
                "Furthest seat from reception"
            ],
            exitLines: [
                "I'll wait just outside — could you call me?",
                "Stepping out for some air.",
                "Just going to make a call."
            ],
            suggestedTechniqueIDs: ["t_distance", "t_shift", "t_musiclyrics", "t_prediction"],
            likelyTriggerIDs: ["tvnextroom", "coughing", "sniffing", "cliketiquette", "legjiggle", "clock", "speakerphone"],
            suggestedMasking: TEMaskPreset.cafe.rawValue),

        TESituationTemplate(
            id: "sharedhome",
            name: "Shared home or kitchen",
            blurb: "The place you cannot avoid, repeated daily. Small permanent changes pay off more here than anywhere.",
            seatingOptions: [
                "Eating at a different time",
                "Different room with the door closed",
                "Extractor fan or radio on as a sound floor",
                "Your own chair, chosen once and kept",
                "Facing away from the main worktop"
            ],
            exitLines: [
                "I'm going to eat in the other room tonight.",
                "Just going to take this upstairs.",
                "Back shortly."
            ],
            suggestedTechniqueIDs: ["t_soundfloor", "t_timing", "s_housemate", "t_bedroom"],
            likelyTriggerIDs: ["cerealmilk", "cutlerydrawer", "chewing", "toothbrush", "footsteps", "tvnextroom", "doorslam"],
            suggestedMasking: TEMaskPreset.fan.rawValue),

        TESituationTemplate(
            id: "sharedbedroom",
            name: "Hotel or shared bedroom",
            blurb: "Triggers plus sleep loss, which compounds faster than anything else in this list.",
            seatingOptions: [
                "Bed furthest from the other person",
                "Head toward the wall away from the corridor",
                "Different room where that is possible",
                "Going to sleep first, before the sound starts",
                "Sofa for part of the night without making it a discussion"
            ],
            exitLines: [
                "I'm going to read next door for a bit.",
                "I'll come through in a while.",
                "Going to try the other room tonight."
            ],
            suggestedTechniqueIDs: ["t_bedroom", "t_soundfloor", "t_pmr", "t_longexhale"],
            likelyTriggerIDs: ["snoring", "loudbreath", "mouthbreath", "clock", "footsteps", "airconhum", "buzzinglight"],
            suggestedMasking: TEMaskPreset.rain.rawValue),

        TESituationTemplate(
            id: "gym",
            name: "Gym",
            blurb: "Loud in general, with very specific sharp triggers inside the noise.",
            seatingOptions: [
                "Machines at the far end from the free weights",
                "Outdoors or a class studio instead",
                "Off-peak hours",
                "Away from mirrors and the stretching mat area",
                "Cardio row nearest the fans"
            ],
            exitLines: [
                "Just moving to another machine.",
                "Taking my set outside.",
                "That's me done for today."
            ],
            suggestedTechniqueIDs: ["t_musiclyrics", "t_timing", "t_distance", "t_walkoff"],
            likelyTriggerIDs: ["headphoneleak", "loudbreath", "doorslam", "rocking", "footsteps", "loudvoice", "keys"],
            suggestedMasking: TEMaskPreset.brown.rawValue),

        TESituationTemplate(
            id: "videocall",
            name: "Video call",
            blurb: "Microphones sit centimeters from people's mouths, which makes calls disproportionately hard.",
            seatingOptions: [
                "Speaker view rather than gallery view",
                "Self-view hidden",
                "Headphones off and laptop speakers low",
                "Camera off when you need to look away",
                "Dial in by phone for long listening-only calls"
            ],
            exitLines: [
                "I'll drop off here — send me the notes.",
                "Losing connection, I'll rejoin.",
                "I'll follow up by message."
            ],
            suggestedTechniqueIDs: ["s_meeting", "t_sightline", "t_shift", "t_bodyscan60"],
            likelyTriggerIDs: ["chewing", "loudbreath", "keyboard", "throatclear", "screenflicker", "seenchewing", "lipsmack"],
            suggestedMasking: TEMaskPreset.none.rawValue)
    ]

    private static let lookup: [String: TESituationTemplate] = {
        var map: [String: TESituationTemplate] = [:]
        for template in all { map[template.id] = template }
        return map
    }()

    static func byID(_ id: String) -> TESituationTemplate? { lookup[id] }

    /// Used when a plan is built from scratch rather than from a template.
    static let blank = TESituationTemplate(
        id: "blank",
        name: "From scratch",
        blurb: "Build the plan yourself. Every option from every template stays available.",
        seatingOptions: [
            "End of the row, nobody on one side",
            "Back to the room",
            "Nearest the exit",
            "Beside the trigger rather than opposite",
            "As far away as the room allows",
            "Standing rather than seated"
        ],
        exitLines: [
            "Back in a minute.",
            "Just going to get some air.",
            "Excuse me for a moment.",
            "I'll be right back."
        ],
        suggestedTechniqueIDs: ["t_seat", "t_54321"],
        likelyTriggerIDs: [],
        suggestedMasking: TEMaskPreset.none.rawValue)

}
