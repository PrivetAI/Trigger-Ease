import Foundation

// The coping deck. Each card is short enough to read while a trigger is going on.
// Nothing here tells the user to relax, to be less sensitive, or to put up with it.

enum TETechniqueCatalog {

    static let all: [TETechnique] = inMoment + bodyCards + attentionCards + thinkingCards
        + environmentCards + communicationCards + afterwardsCards + preparationCards

    private static let lookup: [String: TETechnique] = {
        var map: [String: TETechnique] = [:]
        for card in all { map[card.id] = card }
        return map
    }()

    static func byID(_ id: String) -> TETechnique? { lookup[id] }

    static func inGroup(_ group: TETechniqueGroup) -> [TETechnique] {
        all.filter { $0.group == group }
    }

    static var scripts: [TETechnique] { all.filter { $0.isScript } }

    static func search(_ query: String) -> [TETechnique] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return all }
        return all.filter {
            $0.title.lowercased().contains(q)
                || $0.whenToUse.lowercased().contains(q)
                || $0.steps.joined(separator: " ").lowercased().contains(q)
        }
    }

    // MARK: - In the moment

    static let inMoment: [TETechnique] = [
        TETechnique(id: "t_54321", title: "Five, four, three, two, one",
                    group: .inTheMoment,
                    whenToUse: "The reaction has already started and you need somewhere else for your attention to go.",
                    steps: [
                        "Find five things you can see. Say them silently, with a word each: mug, doorframe, blue coat, window, salt.",
                        "Four things you can feel. The chair, your feet in your shoes, the table edge, the seam of a sleeve.",
                        "Three things you can hear that are not the trigger. This is the hard one, and it is deliberately third.",
                        "Two things you can smell.",
                        "One slow breath, and one thing you can taste.",
                        "If you lose the thread, start again at five. Starting again is not failing at it."
                    ], isScript: false),
        TETechnique(id: "t_nameit", title: "Name it to tame it",
                    group: .inTheMoment,
                    whenToUse: "The anger or panic spike is arriving and you want a half-second of distance from it.",
                    steps: [
                        "Say the state to yourself in plain words: this is the surge, it started about ten seconds ago.",
                        "Label the feeling specifically. Anger and panic and disgust need different responses, and they can be told apart.",
                        "Add the fact that it will peak. Note roughly how long your own surges usually take to fall.",
                        "Do not argue with the feeling or try to justify it. Naming is the whole move."
                    ], isScript: false),
        TETechnique(id: "t_exit", title: "The clean physical exit",
                    group: .inTheMoment,
                    whenToUse: "You are past the point where anything else will work, and staying will cost more than leaving.",
                    steps: [
                        "Decide before you stand up where you are going and for how long. A destination stops it looking like storming out.",
                        "Use your prepared line. Keep it flat and short.",
                        "Go somewhere with a different sound floor — outside, a stairwell, a bathroom, the car.",
                        "Give yourself the full recovery time rather than the minimum polite time.",
                        "Come back on purpose rather than being fetched. That difference matters to how the rest of the evening goes."
                    ], isScript: false),
        TETechnique(id: "t_texture", title: "A competing physical stimulus",
                    group: .inTheMoment,
                    whenToUse: "You cannot leave and you cannot mask, so you need something else with a claim on your attention.",
                    steps: [
                        "Keep a specific object with a strong texture in a pocket: a ridged stone, a cord, a rough coin.",
                        "Work it slowly and deliberately with one hand, under the table.",
                        "Give it real attention — count the ridges, follow a single edge — rather than fiddling absently.",
                        "Press a thumbnail into a fingertip firmly if you need something sharper. Firm pressure, never enough to mark."
                    ], isScript: false),
        TETechnique(id: "t_countdown", title: "Count the sound down",
                    group: .inTheMoment,
                    whenToUse: "The trigger is finite — a bowl of cereal, one course of a meal — and you can see the end of it.",
                    steps: [
                        "Estimate honestly how much longer it will run. Most triggers end sooner than the reaction implies.",
                        "Pick a countable unit and count it: mouthfuls, clicks, sniffs.",
                        "Counting converts an open-ended assault into a finite list, which is a different experience even at the same volume.",
                        "If your estimate runs out and the sound has not, re-estimate once and then switch to a different card."
                    ], isScript: false),
        TETechnique(id: "t_bodyscan60", title: "Sixty-second body sweep",
                    group: .inTheMoment,
                    whenToUse: "You are clenched and had not noticed, which is most of the time.",
                    steps: [
                        "Jaw first: let the teeth come apart and the tongue drop off the roof of the mouth.",
                        "Shoulders: drop them once, deliberately, and let them stay down.",
                        "Hands: open the fingers fully, then rest them.",
                        "Stomach: let it out rather than holding it in.",
                        "Repeat the sweep. Clenching returns within about a minute and that is normal, not a failure."
                    ], isScript: false),
        TETechnique(id: "t_anchorobject", title: "One fixed visual anchor",
                    group: .inTheMoment,
                    whenToUse: "A visual trigger is in your peripheral vision and your eyes keep going back to it.",
                    steps: [
                        "Choose something stationary and slightly detailed to rest your eyes on: a picture, a menu, a pattern in the wood.",
                        "Trace its outline slowly with your gaze, following the edge as if drawing it.",
                        "When your eyes snap back to the movement, return to the anchor without commentary.",
                        "If your seat allows it, reposition so the movement is behind you rather than beside you — that is a better fix than willpower."
                    ], isScript: false)
    ]

    // MARK: - Body and breath

    static let bodyCards: [TETechnique] = [
        TETechnique(id: "t_478", title: "Four, seven, eight breathing",
                    group: .body,
                    whenToUse: "You want to bring the physical surge down and you have a minute of relative quiet.",
                    steps: [
                        "Breathe in through the nose for a slow count of four.",
                        "Hold for seven.",
                        "Breathe out through the mouth for eight, with a little resistance, as if through a straw.",
                        "Four rounds. Stop earlier if you feel light-headed — the point is a longer out-breath, not endurance.",
                        "If seven is too long, use three, five, six. The ratio is what matters."
                    ], isScript: false),
        TETechnique(id: "t_box", title: "Box breathing",
                    group: .body,
                    whenToUse: "You need to stay level and alert rather than wound down — a meeting, an exam, a drive.",
                    steps: [
                        "In for four, hold for four, out for four, hold for four.",
                        "Keep it quiet enough that nobody at the table can hear it.",
                        "Trace the four sides of a square with your eyes or a fingertip as you go.",
                        "Six rounds is about ninety seconds and is usually enough."
                    ], isScript: false),
        TETechnique(id: "t_longexhale", title: "Long exhale only",
                    group: .body,
                    whenToUse: "Counting feels like too much. The simplest version that still works.",
                    steps: [
                        "Breathe in normally. Do not manage the in-breath at all.",
                        "Make the out-breath roughly twice as long as the in-breath.",
                        "Repeat for two minutes.",
                        "That ratio is the active part of nearly every breathing exercise; everything else is scaffolding."
                    ], isScript: false),
        TETechnique(id: "t_pmr", title: "Progressive muscle release",
                    group: .body,
                    whenToUse: "Afterwards, when the sound has stopped but your body has not caught up.",
                    steps: [
                        "Working upward from the feet, tense one muscle group hard for five seconds.",
                        "Release it all at once and notice the drop for ten seconds before moving on.",
                        "Feet, calves, thighs, hands, forearms, shoulders, jaw, forehead.",
                        "Never tense to the point of cramp or pain.",
                        "The whole sequence takes eight to ten minutes and works better lying down."
                    ], isScript: false),
        TETechnique(id: "t_jaw", title: "Jaw and diaphragm release",
                    group: .body,
                    whenToUse: "Your jaw is the place the reaction lands, which is very common.",
                    steps: [
                        "Let the mouth fall very slightly open and rest the tongue on the floor of the mouth.",
                        "Massage the muscle in front of each ear with two fingers, small slow circles, thirty seconds a side.",
                        "Yawn deliberately, wide, twice.",
                        "Put a hand flat on your stomach and take three breaths that move the hand rather than the chest.",
                        "If you wake with jaw pain regularly, that is worth mentioning to a dentist or doctor."
                    ], isScript: false),
        TETechnique(id: "t_cold", title: "Cold on the face or wrists",
                    group: .body,
                    whenToUse: "The surge is very high and you have thirty seconds and access to water.",
                    steps: [
                        "Run cold water over the inside of both wrists for twenty seconds.",
                        "Or hold something cold against the cheekbones and around the eyes.",
                        "Breathe out slowly while you do it.",
                        "Skip this if you have a heart condition or have been told to avoid cold exposure — ask your doctor instead."
                    ], isScript: false),
        TETechnique(id: "t_walkoff", title: "Two minutes of walking",
                    group: .body,
                    whenToUse: "Adrenaline has been released and it needs somewhere to go.",
                    steps: [
                        "Walk at a real pace, not a stroll, for two minutes.",
                        "Outside if possible, stairs if not.",
                        "Let your arms swing. Physical movement metabolises the surge faster than sitting still with it.",
                        "Come back before you have entirely calmed down, so returning is not a decision you have to make twice."
                    ], isScript: false),
        TETechnique(id: "t_grip", title: "Push against something solid",
                    group: .body,
                    whenToUse: "Anger is the dominant feeling and it wants an outlet.",
                    steps: [
                        "Press your palms hard against each other, or push down on the seat of a chair, for ten seconds.",
                        "Release completely.",
                        "Repeat three times.",
                        "It gives the impulse a target that costs nothing and nobody can see."
                    ], isScript: false),
        TETechnique(id: "t_humback", title: "Hum on the out-breath",
                    group: .body,
                    whenToUse: "You are somewhere you can make a small sound without it being odd.",
                    steps: [
                        "Breathe in through the nose, then hum quietly all the way out.",
                        "Feel the vibration in your face and chest rather than listening to the note.",
                        "Six breaths.",
                        "It lengthens the exhale automatically and gives you a sound of your own inside your head."
                    ], isScript: false)
    ]

    // MARK: - Attention

    static let attentionCards: [TETechnique] = [
        TETechnique(id: "t_shift", title: "Deliberate attention shift",
                    group: .attention,
                    whenToUse: "Early, before the reaction has fully arrived. This works best when used soonest.",
                    steps: [
                        "Pick a task with a small demand: a crossword clue, a mental arithmetic problem, reading a label properly.",
                        "It has to have an answer. Passive scrolling does not hold attention against a trigger.",
                        "Give it thirty seconds of real effort.",
                        "Expect your attention to snap back to the sound repeatedly. Return it each time without treating that as failure."
                    ], isScript: false),
        TETechnique(id: "t_rhythmoverlay", title: "Overlay your own rhythm",
                    group: .attention,
                    whenToUse: "The trigger is rhythmic — tapping, clicking, chewing.",
                    steps: [
                        "Tap a different rhythm quietly with one finger, out of phase with theirs.",
                        "Use three against four, or any pattern that will not lock to their pulse.",
                        "Or count a slow beat in your head that does not divide into theirs.",
                        "It stops your attention being entrained by their timing, which is a large part of what makes rhythmic triggers so gripping."
                    ], isScript: false),
        TETechnique(id: "t_conversation", title: "Take over the talking",
                    group: .attention,
                    whenToUse: "At a table, where the trigger stops while somebody speaks.",
                    steps: [
                        "Ask an open question of the person making the sound.",
                        "People rarely chew and answer at the same time, so you buy quiet and it looks like interest.",
                        "Keep follow-up questions ready so the gap does not close.",
                        "This is tiring to sustain. Treat it as a bridge to the end of the course, not a plan for the evening."
                    ], isScript: false),
        TETechnique(id: "t_narrate", title: "Narrate the room",
                    group: .attention,
                    whenToUse: "You need something to occupy the language part of your head.",
                    steps: [
                        "Describe the room silently in full sentences, as if writing it down for someone.",
                        "Be specific: colors, materials, what is worn, what the light is doing.",
                        "Inner speech is hard to run at the same time as monitoring a sound.",
                        "Keep going for a minute or two, then check whether the surge has dropped."
                    ], isScript: false),
        TETechnique(id: "t_musiclyrics", title: "Lyrics, not instrumentals",
                    group: .attention,
                    whenToUse: "You can wear one earphone and want the strongest available distraction.",
                    steps: [
                        "Choose something with words that you know well enough to follow but not so well that it is wallpaper.",
                        "Keep the volume low — the goal is competition for attention, not drowning the room out.",
                        "Instrumentals leave the language channel free, which is where trigger monitoring tends to live.",
                        "One earphone keeps you in the conversation and is far less conspicuous than two."
                    ], isScript: false),
        TETechnique(id: "t_prediction", title: "Predict the next one",
                    group: .attention,
                    whenToUse: "Irregular triggers where the waiting is worse than the sound.",
                    steps: [
                        "Guess when the next occurrence will be. Count the seconds.",
                        "Score yourself against it.",
                        "Turning anticipation into a game removes some of the dread from the gap.",
                        "Stop if it makes you monitor more closely rather than less. It does not suit everyone."
                    ], isScript: false)
    ]

    // MARK: - Thinking it through

    static let thinkingCards: [TETechnique] = [
        TETechnique(id: "t_reframe_anger", title: "The anger spike is information",
                    group: .thinking,
                    whenToUse: "When the wave of anger arrives and you feel bad about having it.",
                    steps: [
                        "The spike is a fast automatic response. It arrives before you have any say in it.",
                        "Having it does not make you an angry person, and it is not a judgment you passed on anyone.",
                        "What you do in the next thirty seconds is yours. The spike itself is not.",
                        "Separating those two things reliably lowers the second wave — the shame that follows the anger."
                    ], isScript: false),
        TETechnique(id: "t_notaboutyou", title: "They are not doing it at you",
                    group: .thinking,
                    whenToUse: "When it starts to feel deliberate, which it very often does.",
                    steps: [
                        "Almost nobody can hear their own chewing, sniffing or tapping.",
                        "The sound is not aimed. It would happen identically in an empty room.",
                        "This does not mean you have to put up with it. It means the conversation is a request, not an accusation.",
                        "Holding both of those at once is the useful position."
                    ], isScript: false),
        TETechnique(id: "t_notoversensitive", title: "You are not being oversensitive",
                    group: .thinking,
                    whenToUse: "After somebody has told you that you are.",
                    steps: [
                        "The reaction is involuntary and physical. You do not choose it and you cannot decide your way out of it.",
                        "Plenty of people report exactly the same pattern, in the same order, to the same handful of sounds.",
                        "Somebody else not hearing a problem is not evidence that there is not one.",
                        "You are allowed to find something intolerable that another person finds unremarkable."
                    ], isScript: false),
        TETechnique(id: "t_worstcase", title: "Check the actual cost of leaving",
                    group: .thinking,
                    whenToUse: "You are trapped by the social cost of standing up.",
                    steps: [
                        "Name concretely what you think will happen if you leave the table for five minutes.",
                        "Ask how likely that actually is, and what it would cost if it happened.",
                        "Compare it against the cost of another forty minutes of this.",
                        "Very often the real answer is that nobody will comment, and the trap was mostly anticipation."
                    ], isScript: false),
        TETechnique(id: "t_nofault", title: "Nobody here is the villain",
                    group: .thinking,
                    whenToUse: "When the situation is heading toward a fight.",
                    steps: [
                        "They are eating. That is not a wrong they are committing.",
                        "You are having an involuntary reaction. That is not a wrong you are committing either.",
                        "The problem is the arrangement of the room, not the character of anyone in it.",
                        "Arrangements can be changed by asking. Characters cannot, and arguing about them ends the conversation."
                    ], isScript: false),
        TETechnique(id: "t_todayonly", title: "Rate today, not forever",
                    group: .thinking,
                    whenToUse: "When one bad episode starts to feel like proof about the rest of your life.",
                    steps: [
                        "Ask what was different today: sleep, hunger, stress load, how long you had already been coping.",
                        "Triggers hit harder on a bad baseline. That is a state, not a trajectory.",
                        "Log it and let the journal answer the trend question later, with data rather than a mood.",
                        "One difficult meal is one difficult meal."
                    ], isScript: false),
        TETechnique(id: "t_permission", title: "Permission to protect yourself",
                    group: .thinking,
                    whenToUse: "When you are about to endure something you do not need to endure.",
                    steps: [
                        "Ask what you would tell a friend in the same chair.",
                        "You would almost certainly tell them to move seats or step out.",
                        "Take the same permission. Enduring it silently is not a moral achievement.",
                        "Nobody is scoring you on how long you stayed."
                    ], isScript: false)
    ]

    // MARK: - Room and position

    static let environmentCards: [TETechnique] = [
        TETechnique(id: "t_seat", title: "Choose the seat before you sit",
                    group: .environment,
                    whenToUse: "Any table, any room where you get to pick.",
                    steps: [
                        "Arrive early enough to have a choice. This one decision often outweighs everything else in the plan.",
                        "Sit at the end rather than the middle — it halves the number of people either side of you.",
                        "Put your better ear toward the quieter side if your ears differ.",
                        "Sit beside a known trigger rather than opposite them: you lose the sightline, which removes the visual half.",
                        "Have a route out that does not cross the room."
                    ], isScript: false),
        TETechnique(id: "t_sightline", title: "Break the sightline",
                    group: .environment,
                    whenToUse: "Visual triggers, or a sound trigger that is worse when you can see its source.",
                    steps: [
                        "Move so a plant, a menu, a laptop screen or a person is between you and the movement.",
                        "Angle your chair rather than moving it — less noticeable, nearly as effective.",
                        "If you cannot move, hold something up in your left or right visual field for a while.",
                        "Watching the source almost always makes the sound worse. Test that for yourself once and you will stop looking."
                    ], isScript: false),
        TETechnique(id: "t_soundfloor", title: "Raise the sound floor",
                    group: .environment,
                    whenToUse: "At home or in your own workspace, where you control the room.",
                    steps: [
                        "A trigger stands out most against silence. A quiet continuous background reduces the contrast.",
                        "A fan, an extractor, an open window onto traffic, or the app's masking presets all work.",
                        "Set it before the trigger starts, not after. Adding it mid-episode works far less well.",
                        "Keep it low enough that you stop noticing it within a minute."
                    ], isScript: false),
        TETechnique(id: "t_earplugs", title: "Filtered earplugs, not foam",
                    group: .environment,
                    whenToUse: "Restaurants, offices, public transport, family meals.",
                    steps: [
                        "Flat-attenuation musicians' plugs reduce everything by a similar amount, so speech stays intelligible.",
                        "Foam plugs cut the high frequencies hardest and leave chewing and bass largely intact.",
                        "Carry them where you will actually have them, not in a drawer at home.",
                        "Some people find full silence makes internal monitoring worse — if that is you, use plugs plus a low sound floor.",
                        "If you are relying on plugs for most of your waking hours, that is worth raising with an audiologist."
                    ], isScript: false),
        TETechnique(id: "t_distance", title: "Buy distance instead of silence",
                    group: .environment,
                    whenToUse: "Open-plan offices, waiting rooms, shared study spaces.",
                    steps: [
                        "Sound falls off sharply with distance. Two meters further away is often worth more than any headphone.",
                        "Move to a corner, a far table, a different bank of desks.",
                        "Hard surfaces reflect — sitting near soft furnishings, curtains or bookshelves quietens a room noticeably.",
                        "Ask for a permanent move rather than shuffling every day. See the desk move script."
                    ], isScript: false),
        TETechnique(id: "t_timing", title: "Shift the timing",
                    group: .environment,
                    whenToUse: "Recurring, scheduled exposures such as a shared kitchen or a canteen.",
                    steps: [
                        "Eat fifteen minutes before or after everyone else.",
                        "Take the earlier train, the later gym slot, the first cinema showing of the day.",
                        "Small timing shifts often remove a trigger completely and cost you nothing socially.",
                        "It is not avoidance in a harmful sense; it is scheduling."
                    ], isScript: false),
        TETechnique(id: "t_bedroom", title: "Make the shared bedroom workable",
                    group: .environment,
                    whenToUse: "Breathing or snoring from a partner is costing you sleep.",
                    steps: [
                        "Continuous low masking through the whole night, started before you get in, not after you are lying awake.",
                        "Sleep-specific earbuds or side-sleeper plugs rather than standard ones.",
                        "Go to bed at slightly different times so you are asleep before the sound starts.",
                        "Separate rooms some nights is a legitimate arrangement, not a verdict on the relationship.",
                        "Loud snoring is worth a medical opinion for their sake as well as yours."
                    ], isScript: false),
        TETechnique(id: "t_car", title: "Set the car up first",
                    group: .environment,
                    whenToUse: "Long journeys, where you cannot leave and cannot move.",
                    steps: [
                        "Agree the sound plan before setting off, while nobody is annoyed.",
                        "Front seat if you are the passenger — fewer people in your field, and road noise helps.",
                        "Music or a podcast on from the start rather than introduced later as a complaint.",
                        "Agree stops in advance: every ninety minutes, whether or not anyone needs one."
                    ], isScript: false),
        TETechnique(id: "t_office", title: "Build an office kit",
                    group: .environment,
                    whenToUse: "You are in the same room with the same people every day.",
                    steps: [
                        "Over-ear headphones do double duty: they attenuate, and they are a visible signal not to interrupt.",
                        "Keep a low masking sound running rather than music, so you can still think.",
                        "Book a quiet room for the work that needs real concentration, ahead of time, as a standing booking.",
                        "Have one colleague who knows, so a bad afternoon does not need explaining from scratch."
                    ], isScript: false)
    ]

    // MARK: - Communication scripts

    static let communicationCards: [TETechnique] = [
        TETechnique(id: "s_family_habit", title: "Asking a family member to change a habit",
                    group: .communication,
                    whenToUse: "Away from the table, at a neutral time, not mid-episode.",
                    steps: [
                        "\"Can I ask you something that is a bit awkward? It is not a criticism of you.\"",
                        "\"There are certain sounds that set off a really strong physical reaction in me. It is not annoyance — my heart rate goes up and I can't think straight.\"",
                        "\"One of them happens at dinner. I know you are not doing anything wrong, and I know how strange this sounds.\"",
                        "\"What would help me most is [one specific thing]. If that is difficult, I can sit at the end instead — that also works.\"",
                        "\"I'm not asking you to change how you eat forever. I'm asking for help with one meal at a time.\"",
                        "Then stop talking and let them respond. One request, one meal, one specific change."
                    ], isScript: true),
        TETechnique(id: "s_partner", title: "Telling a new partner",
                    group: .communication,
                    whenToUse: "Early, before the first time they see you go quiet and cold at a meal.",
                    steps: [
                        "\"There's something about me I'd rather you heard from me than worked out.\"",
                        "\"Certain repetitive sounds — mostly eating and breathing sounds — cause a really intense reaction in me. It is involuntary and it is physical.\"",
                        "\"If I suddenly go quiet or leave the room, it is almost never about you or about anything you said.\"",
                        "\"It would help if we had a signal, so I can tell you without making it a whole conversation in front of people.\"",
                        "\"I'll tell you what actually helps as we go. Mostly it is where I sit and having background sound on.\"",
                        "\"You don't have to fix it. Just don't tell me it is nothing.\""
                    ], isScript: true),
        TETechnique(id: "s_desk_move", title: "Requesting a desk move at work",
                    group: .communication,
                    whenToUse: "With a manager or facilities, in writing if you can — it travels better.",
                    steps: [
                        "\"I'd like to ask about moving desks. It is a working-environment issue rather than anything to do with the team.\"",
                        "\"I'm very sensitive to certain repetitive sounds. In my current spot it costs me a significant amount of focused time every day.\"",
                        "\"A corner desk, or one further from the walkway, would make a measurable difference to my output.\"",
                        "\"I'm already using over-ear headphones and background sound. This would be the remaining piece.\"",
                        "\"If a move isn't possible, could I book a quiet room for two focused blocks a week as a standing arrangement?\"",
                        "Keep it about work output. You do not owe anybody a medical explanation to justify a chair."
                    ], isScript: true),
        TETechnique(id: "s_exam", title: "Asking for exam or study accommodations",
                    group: .communication,
                    whenToUse: "With a school, university or exam board, well ahead of the date.",
                    steps: [
                        "\"I want to ask about arrangements for exam conditions. Certain repetitive sounds cause a strong involuntary reaction that affects my concentration.\"",
                        "\"In a silent hall, sniffing, coughing and pen clicking are extremely difficult for me.\"",
                        "\"What would help is a smaller room, or a seat at the edge, or permission to wear filtered earplugs.\"",
                        "\"What documentation do you need from me, and what is the deadline for it?\"",
                        "Ask early — most institutions have a cut-off date well before the exam period.",
                        "Ask for the answer in writing, and keep it for next year."
                    ], isScript: true),
        TETechnique(id: "s_sceptic", title: "Explaining it to someone who thinks you are being dramatic",
                    group: .communication,
                    whenToUse: "When you have been told to get over it and you want one more attempt.",
                    steps: [
                        "\"I know it sounds like I'm making a fuss about something small. Let me describe what actually happens.\"",
                        "\"When I hear it, my body reacts before I have any say in it — heart rate up, jaw tight, a strong urge to get away.\"",
                        "\"It is not that the sound is loud. It is that this particular sound does that to me, every time.\"",
                        "\"Think of the worst noise you can imagine — nails on a blackboard, polystyrene squeaking. That is roughly the response, but to chewing.\"",
                        "\"I'm not asking you to understand it. I'm asking you to believe me that it is happening.\"",
                        "If they still dismiss it, stop there. You are not required to keep proving it."
                    ], isScript: true),
        TETechnique(id: "s_handsignal", title: "Agreeing a hand signal",
                    group: .communication,
                    whenToUse: "With family or a partner, set up in advance so it never has to be explained in the moment.",
                    steps: [
                        "Agree one small gesture that means \"this is happening now\" — a hand flat on the table, touching an ear.",
                        "Agree exactly what it obliges the other person to do: nothing, or change the subject, or turn the extractor fan on.",
                        "Agree what it does not mean: it is not an accusation and it does not require an apology.",
                        "Agree a second signal for \"I am leaving the table and I am fine.\"",
                        "Practice it once when nothing is wrong, so the first use is not also the first explanation."
                    ], isScript: true),
        TETechnique(id: "s_restaurant", title: "Asking to change tables",
                    group: .communication,
                    whenToUse: "Restaurants, cafés, waiting rooms.",
                    steps: [
                        "\"Would it be possible to move to that table by the wall? Thank you — I'm sensitive to noise.\"",
                        "That is the whole script. No further explanation is needed or expected.",
                        "Ask when you are seated rather than after twenty minutes, when it becomes a complaint.",
                        "If you are booking ahead, ask for a quiet table then — most places will note it."
                    ], isScript: true),
        TETechnique(id: "s_child", title: "Talking to a child about their sounds",
                    group: .communication,
                    whenToUse: "When a child is the trigger and you do not want them to carry it.",
                    steps: [
                        "Never make the child responsible for managing your reaction. That is the whole rule.",
                        "\"My ears are funny about some sounds. It is a me thing, not a you thing.\"",
                        "\"When I go and sit in the other room for a bit, it is nothing you did wrong.\"",
                        "Change what you can on your side: where you sit, background sound, the timing of meals.",
                        "Ask another adult to cover the meal on the hardest days rather than pushing through visibly."
                    ], isScript: true),
        TETechnique(id: "s_teen", title: "Talking to a teenager who has it",
                    group: .communication,
                    whenToUse: "When you are the parent and your child is the one reacting.",
                    steps: [
                        "\"I believe you. I'm not going to tell you it is nothing.\"",
                        "\"Let's work out which sounds and which situations, so we can change the ones we can change.\"",
                        "\"You are allowed to leave the table. Tell me you are going and that is enough.\"",
                        "\"You are not in trouble for reacting. We will work on how you leave, not on whether you can.\"",
                        "Ask what they want you to say to other people, and say exactly that.",
                        "If it is affecting school, sleep or friendships, ask their doctor about a referral."
                    ], isScript: true),
        TETechnique(id: "s_housemate", title: "Raising it with a housemate",
                    group: .communication,
                    whenToUse: "Shared kitchens, thin walls, shared bathrooms.",
                    steps: [
                        "\"Can I ask a favour about the flat? It is a me problem but you can help with it easily.\"",
                        "\"Certain sounds through the wall are really hard for me, especially late.\"",
                        "\"Would you mind [one specific thing]? I'll do the same for anything on your side.\"",
                        "Offer a trade. It converts a complaint into an arrangement.",
                        "Put the agreed thing somewhere visible so nobody has to remember a conversation."
                    ], isScript: true),
        TETechnique(id: "s_meeting", title: "Managing a video call",
                    group: .communication,
                    whenToUse: "Calls where somebody eats, breathes or types close to their microphone.",
                    steps: [
                        "\"Could everyone mute when not speaking? The microphones are picking up a lot of room noise.\"",
                        "Framing it as audio quality is true and requires no disclosure.",
                        "If you are the host, mute participants on entry as a standing default.",
                        "Hide your own self-view and pin the speaker to reduce visual triggers in the grid.",
                        "Where the platform allows it, switch to speaker view rather than gallery view."
                    ], isScript: true),
        TETechnique(id: "s_apology", title: "Repairing it after you snapped",
                    group: .communication,
                    whenToUse: "Afterwards, when you reacted harder than you wanted to.",
                    steps: [
                        "\"I'm sorry about how I said that. The way I said it was not fair on you.\"",
                        "\"What I was reacting to was real, and I still need to sort that out. But you didn't deserve the tone.\"",
                        "Apologize for the delivery. Do not apologize for having the reaction — that is not yours to apologize for.",
                        "Then make one concrete suggestion for next time, so the repair ends somewhere useful."
                    ], isScript: true),
        TETechnique(id: "s_gp", title: "Raising it with a doctor",
                    group: .communication,
                    whenToUse: "When it is affecting sleep, work, study or relationships.",
                    steps: [
                        "\"I have a strong involuntary reaction to specific repetitive sounds. It is affecting [sleep / work / how I eat with my family].\"",
                        "\"It has been going on for about [x] years and it has got [worse / more frequent].\"",
                        "\"I've brought a record of when it happens and how bad it gets.\"",
                        "\"Is a referral available — audiology, or a psychologist who has come across this?\"",
                        "Some clinicians will not have heard the word misophonia. Describing the pattern plainly works better than leading with the label.",
                        "Take your journal summary with you. Written records are taken seriously."
                    ], isScript: true)
    ]

    // MARK: - Afterwards

    static let afterwardsCards: [TETechnique] = [
        TETechnique(id: "t_recover", title: "Deliberate recovery time",
                    group: .afterwards,
                    whenToUse: "Immediately after an episode ends.",
                    steps: [
                        "The physical surge outlasts the sound, often by fifteen to forty minutes.",
                        "Do not judge the situation, the person or yourself while it is still coming down.",
                        "Do something undemanding and physical: walk, tidy, wash up, stretch.",
                        "Note your own typical recovery time from the journal. Knowing it is coming down helps while it is coming down."
                    ], isScript: false),
        TETechnique(id: "t_logit", title: "Log it while it is fresh",
                    group: .afterwards,
                    whenToUse: "Within an hour, before the details blur.",
                    steps: [
                        "Trigger, place, who, intensity, what you did, how long recovery took.",
                        "Two lines is enough. A perfect entry you never write is worth nothing.",
                        "Patterns you cannot see day to day become obvious across thirty entries.",
                        "It also gives you something concrete to show a clinician or a family member."
                    ], isScript: false),
        TETechnique(id: "t_noshame", title: "Head off the second wave",
                    group: .afterwards,
                    whenToUse: "When the shame arrives after the anger has gone.",
                    steps: [
                        "The reaction was involuntary. Having it is not a character flaw.",
                        "If you were sharp with someone, repair that specific thing — see the repair script — and let the rest go.",
                        "Do not replay the episode looking for evidence about yourself.",
                        "Write one line about what you would change in the setup next time, and close it."
                    ], isScript: false),
        TETechnique(id: "t_review", title: "Review the plan honestly",
                    group: .afterwards,
                    whenToUse: "After a planned situation, while you can still remember what you actually did.",
                    steps: [
                        "Score the difficulty first, before you decide what worked, so the score is not contaminated.",
                        "Mark honestly which techniques you actually used. Nothing is gained by crediting one you never reached for.",
                        "Rate how much each helped, including the ones that did nothing.",
                        "Over enough repeats the ranking becomes yours rather than generic advice."
                    ], isScript: false),
        TETechnique(id: "t_treat", title: "Put something afterwards",
                    group: .afterwards,
                    whenToUse: "Before a situation you already know will be hard.",
                    steps: [
                        "Arrange something quiet and pleasant immediately after: a walk home alone, a shower, an hour with headphones.",
                        "Knowing there is an end and a decompression point changes how the middle feels.",
                        "Tell whoever you are with that you will be heading off afterwards, so leaving is already agreed.",
                        "This is not a reward for good behavior. It is a recovery slot, and it should be routine."
                    ], isScript: false)
    ]

    // MARK: - Before it starts

    static let preparationCards: [TETechnique] = [
        TETechnique(id: "t_baseline", title: "Check your baseline first",
                    group: .preparation,
                    whenToUse: "On the day, before you go.",
                    steps: [
                        "Tired, hungry, already stressed — every one of these lowers your tolerance measurably.",
                        "Eat before a difficult meal so hunger is not adding to it.",
                        "If you have slept badly, plan for a shorter stay rather than the usual one.",
                        "This is the cheapest intervention available and it is the one most often skipped."
                    ], isScript: false),
        TETechnique(id: "t_prepack", title: "Pack the kit the night before",
                    group: .preparation,
                    whenToUse: "Any planned situation.",
                    steps: [
                        "Filtered earplugs, one earphone, a charged phone, the textured object.",
                        "Put it by the door. A kit at home is not a kit.",
                        "Check what your masking preset sounds like at the level you will actually use.",
                        "Two minutes the night before removes a whole class of problems on the day."
                    ], isScript: false),
        TETechnique(id: "t_scripted_exit", title: "Write the exit line in advance",
                    group: .preparation,
                    whenToUse: "Before any situation you might need to leave.",
                    steps: [
                        "Write the exact sentence. Improvising under a surge is unreliable.",
                        "Keep it flat and boring: \"Back in a minute\", \"Just going to get some air.\"",
                        "Do not explain and do not apologise. An explanation invites a discussion you do not want then.",
                        "Say it as a statement, not a question, and be already standing."
                    ], isScript: false),
        TETechnique(id: "t_ally", title: "Brief one person beforehand",
                    group: .preparation,
                    whenToUse: "Group situations where you will not be able to explain in the moment.",
                    steps: [
                        "Tell one person before it starts, in one sentence, and tell them what you need from them.",
                        "Usually that is: cover for me if I step out, and do not make it a topic.",
                        "Having one person who already knows removes most of the social cost of leaving.",
                        "Thank them afterwards, briefly, so it stays easy to ask again."
                    ], isScript: false),
        TETechnique(id: "t_shorterstay", title: "Set the length before you arrive",
                    group: .preparation,
                    whenToUse: "Recurring events you dread.",
                    steps: [
                        "Decide the leaving time in advance and say it on arrival: \"I can stay until about nine.\"",
                        "A stated end time is accepted without comment. An unannounced early exit rarely is.",
                        "Ninety good minutes are worth more to everyone than three grim hours.",
                        "You can always stay longer. That direction never causes a problem."
                    ], isScript: false),
        TETechnique(id: "t_dryrun", title: "Rehearse the first ninety seconds",
                    group: .preparation,
                    whenToUse: "High-stakes situations: a first meeting with a partner's family, a viva, a flight.",
                    steps: [
                        "Picture arriving, choosing the seat, and the first sound landing.",
                        "Rehearse exactly what you will do in the first ninety seconds — which card, which position.",
                        "Rehearsing the plan rather than the disaster is the point.",
                        "Two run-throughs is enough. More becomes rumination."
                    ], isScript: false)
    ]
}
