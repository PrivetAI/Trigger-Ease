import Foundation

// The Learn library. Written to be honest about what is and is not known, and never to tell the
// user they have a disorder. Nothing here is medical advice.

enum TELearnCatalog {

    static let sections: [String] = [
        "What it is",
        "Related conditions",
        "Living with it",
        "Other people",
        "Support and evidence"
    ]

    static let all: [TELearnCard] = whatItIs + related + living + others + support

    private static let lookup: [String: TELearnCard] = {
        var map: [String: TELearnCard] = [:]
        for card in all { map[card.id] = card }
        return map
    }()

    static func byID(_ id: String) -> TELearnCard? { lookup[id] }

    static func inSection(_ section: String) -> [TELearnCard] {
        all.filter { $0.section == section }
    }

    static func search(_ query: String) -> [TELearnCard] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return all }
        return all.filter {
            $0.title.lowercased().contains(q) || $0.paragraphs.joined(separator: " ").lowercased().contains(q)
        }
    }

    // MARK: - What it is

    static let whatItIs: [TELearnCard] = [
        TELearnCard(id: "l_what", title: "What misophonia is", section: "What it is", paragraphs: [
            "Misophonia describes a strong, involuntary reaction to specific everyday sounds — most often repetitive sounds made by other people, such as chewing, sniffing, breathing, pen clicking or tapping.",
            "The reaction is not simply irritation. People describe a fast physical surge — heart rate up, muscles tight, heat, a powerful urge to escape — arriving within a second or two of the sound and often accompanied by anger, panic or disgust.",
            "It is usually very specific. The same sound from a stranger and from a family member can produce completely different responses, and the volume of the sound is frequently irrelevant.",
            "This app does not decide whether you have anything. It gives you a place to record what happens and to prepare for the situations you already know are hard."
        ]),
        TELearnCard(id: "l_classification", title: "How it is classified — honestly", section: "What it is", paragraphs: [
            "Misophonia is not currently listed as a distinct disorder in the major diagnostic manuals used by clinicians. It does not have its own entry in the DSM or the ICD.",
            "That is a statement about classification, not about whether the experience is real. Research groups have published proposed definitions and consensus statements, and interest in the topic has grown considerably.",
            "The practical consequence is that different clinicians handle it differently, and some will not have heard the term. Describing what actually happens to you, in plain language, tends to work better than leading with the word.",
            "Anyone who tells you the science is settled — in either direction — is overstating it. This app tries not to do that."
        ]),
        TELearnCard(id: "l_involuntary", title: "Why the reaction is involuntary", section: "What it is", paragraphs: [
            "The response is faster than deliberation. By the time you are aware of having reacted, the physical part has already happened.",
            "Research using brain imaging has reported differences in how trigger sounds are processed by people who report misophonia, including stronger responses in regions involved in emotional salience and in areas linked to the movements that produce the sound.",
            "That work is ongoing and no single finding should be treated as the explanation. What it does support is the everyday observation people report: this is not a decision.",
            "Practically, it means willpower is the wrong tool. Preparation, positioning and recovery are better targets, because they act on things you can actually change."
        ]),
        TELearnCard(id: "l_onset", title: "When it usually starts", section: "What it is", paragraphs: [
            "Many people describe it beginning in childhood or early adolescence, frequently with one specific trigger and one specific person — very often a parent or sibling at the dinner table.",
            "Some people describe it appearing later, or after a period of high stress. Others cannot place a start at all.",
            "The trigger set tends to widen over time for some people and stay narrow for others. Neither pattern is a rule.",
            "If you have only ever had one trigger and it has not changed in twenty years, that is entirely consistent with what people report."
        ]),
        TELearnCard(id: "l_specificity", title: "Why it is so specific", section: "What it is", paragraphs: [
            "People often find that the identical sound is fine from one source and intolerable from another: their own chewing is fine, a stranger's is bearable, a family member's is not.",
            "Context, relationship and expectation all seem to matter. So does whether you can see the person making the sound.",
            "This specificity is one reason misophonia is so easy to dismiss from the outside. If it were about loudness it would be obvious; because it is about a particular sound from a particular person, it looks like a preference.",
            "Recording which combinations are worst is genuinely useful, both to you and to anyone you eventually explain it to."
        ]),
        TELearnCard(id: "l_visual", title: "Misokinesia — the visual side", section: "What it is", paragraphs: [
            "Some people react the same way to repetitive movement seen rather than heard: a jiggling leg, a twirling pen, a hand returning to the same place. This is usually called misokinesia.",
            "Surveys have found visual triggers reported by a substantial proportion of people who also report sound triggers, and by some people who report no sound trigger at all.",
            "It is often left out of trigger lists entirely, which leaves people who have it assuming they are describing something nobody else has.",
            "This app includes visual triggers in the catalogue as their own class for exactly that reason."
        ]),
        TELearnCard(id: "l_intensity", title: "Why the same trigger varies day to day", section: "What it is", paragraphs: [
            "Nearly everyone reports that the same sound is worse on some days than others.",
            "Sleep, hunger, stress, illness, and how long you have already been coping all appear to move the threshold.",
            "Being unable to escape makes it worse independently of the sound: a trigger in a car is generally reported as harder than the same trigger in a room you can leave.",
            "The journal in this app records the day as well as the trigger, which is what lets you see this rather than guess at it."
        ]),
        TELearnCard(id: "l_notrare", title: "How common it is", section: "What it is", paragraphs: [
            "Prevalence estimates vary widely — from a few percent to well over a tenth of the population depending on the definition and the threshold used.",
            "That spread is mostly a measurement problem: there is no agreed cut-off between finding chewing unpleasant and having a reaction that disrupts your life.",
            "What the estimates do consistently show is that it is not vanishingly rare. If you have it, you are not one in a million.",
            "Treat any single confident number you see quoted with suspicion, including a low one."
        ])
    ]

    // MARK: - Related conditions

    static let related: [TELearnCard] = [
        TELearnCard(id: "l_hyperacusis", title: "How it differs from hyperacusis", section: "Related conditions", paragraphs: [
            "Hyperacusis is a reduced tolerance to ordinary sound levels — sounds that most people find comfortable are experienced as too loud, sometimes painfully so.",
            "It is about volume and it applies broadly. A vacuum cleaner, a hand dryer or a slammed door are typical examples.",
            "Misophonia is about which sound it is, not how loud. A very quiet sniff can produce a full reaction while a loud machine produces none.",
            "The two can occur together, and if sound is causing you actual physical discomfort or pain, that is worth raising with an audiologist."
        ]),
        TELearnCard(id: "l_phonophobia", title: "How it differs from phonophobia", section: "Related conditions", paragraphs: [
            "Phonophobia describes fear of sound — typically anticipatory anxiety about a sound occurring, such as a balloon popping or a sudden bang.",
            "The dominant emotion in misophonia is more often anger, disgust or a trapped feeling rather than fear, though anxiety about upcoming exposure is very commonly reported alongside it.",
            "The distinction matters mostly because it points at different approaches — and because being told your problem is anxiety, when it does not feel like anxiety, is unhelpful.",
            "These categories overlap in practice and the boundaries are not sharp."
        ]),
        TELearnCard(id: "l_tinnitus", title: "How it differs from tinnitus", section: "Related conditions", paragraphs: [
            "Tinnitus is the perception of a sound — ringing, hissing, buzzing — with no external source.",
            "It is a separate phenomenon from misophonia, but the two are often discussed together because both are managed partly through sound and both are handled by audiology services.",
            "Some people have both. Masking sound is used in both contexts, though for different reasons: to reduce contrast in one case and to reduce the salience of an internal sound in the other.",
            "New, sudden or one-sided tinnitus should be checked by a doctor rather than managed with an app."
        ]),
        TELearnCard(id: "l_anxiety", title: "Overlap with anxiety and low mood", section: "Related conditions", paragraphs: [
            "People who report misophonia frequently also report anxiety, and it is not always clear which direction the relationship runs.",
            "Dreading a meal for three days beforehand, and withdrawing from situations because of it, are both understandable consequences rather than evidence of a separate problem.",
            "Isolation is the most common secondary cost people describe: declining invitations is effective in the short term and expensive over a year.",
            "If low mood or anxiety is becoming the larger problem, that on its own is a good reason to talk to a professional, independent of the sound question."
        ]),
        TELearnCard(id: "l_adhdautism", title: "Sensory sensitivity more broadly", section: "Related conditions", paragraphs: [
            "Heightened sensory sensitivity is reported in a range of contexts, including by many autistic people and by people with ADHD.",
            "Some people find that a broader sensory profile explains more of their experience than misophonia alone does — for example if bright light, textures, labels in clothing or crowded rooms are also difficult.",
            "This app does not assess any of that and cannot tell you anything about it.",
            "If the pattern looks broader than sound to you, that is a useful thing to mention to a clinician."
        ]),
        TELearnCard(id: "l_ocd", title: "When monitoring becomes the problem", section: "Related conditions", paragraphs: [
            "Some people describe a loop where they scan for the trigger continuously, which makes it far more likely they will notice it.",
            "Checking whether the sound has started, or repeatedly testing whether you still react, tends to strengthen the pattern rather than settle it.",
            "That is one reason this app has no counters, no streaks and no daily prompts. There is nothing here designed to make you check in.",
            "If checking and monitoring have become intrusive in themselves, mention that specifically to a professional — it is a well-recognized pattern with recognized approaches."
        ])
    ]

    // MARK: - Living with it

    static let living: [TELearnCard] = [
        TELearnCard(id: "l_lovedones", title: "Why loved ones are often the hardest", section: "Living with it", paragraphs: [
            "It is extremely common for the strongest triggers to come from the people closest to you — a parent, a partner, a sibling, a child.",
            "Several things stack up: exposure is frequent, escape is socially costly, and the relationship means the sound arrives loaded with history.",
            "It is also the situation people feel worst about, because the anger is directed at someone they love and did not choose to feel it toward.",
            "Nothing about that is a statement on the relationship. Separating the reaction from the person is difficult and it is worth doing deliberately."
        ]),
        TELearnCard(id: "l_sleep", title: "Sleep and shared bedrooms", section: "Living with it", paragraphs: [
            "Breathing and snoring are among the most reported triggers, and they arrive in the quietest room you spend time in.",
            "Sleep loss then lowers the next day's threshold, which is why this particular combination escalates faster than most.",
            "Practical arrangements that people report using: continuous low masking started before bed, sleep-specific earplugs, staggered bedtimes, and separate rooms on some nights.",
            "Sleeping separately is a scheduling decision, not a verdict on a relationship. Persistent loud snoring is worth a medical opinion for the other person's sake too."
        ]),
        TELearnCard(id: "l_work", title: "Work accommodations", section: "Living with it", paragraphs: [
            "The things people most often ask for are a desk move, permission to wear headphones or filtered earplugs, and access to a quiet room for focused work.",
            "Framing the request around output rather than around a medical explanation usually works better and requires you to disclose less.",
            "Ask in writing where you can, and ask for the answer in writing. It makes the arrangement durable when a manager changes.",
            "Employment law and formal adjustment processes differ by country. If a reasonable request is refused, it is worth finding out what your local framework actually provides."
        ]),
        TELearnCard(id: "l_school", title: "School and university", section: "Living with it", paragraphs: [
            "Exam halls concentrate the problem: enforced silence, a fixed seat, a time limit and high stakes all at once.",
            "Commonly available arrangements include a smaller room, a seat at the edge or front, permission to use earplugs, and extra time.",
            "Deadlines for arranging these are usually well before the exam period, so asking early matters more than asking well.",
            "For a younger child, a class teacher can often change a seat immediately without any formal process at all."
        ]),
        TELearnCard(id: "l_eatingtogether", title: "Eating with other people", section: "Living with it", paragraphs: [
            "Shared meals are where most people first notice the problem, and they carry a large amount of social weight.",
            "Practical changes people report using: sitting at the end, sitting beside rather than opposite, arriving early enough to choose, background sound, eating slightly out of sync.",
            "Declining every meal is effective and costly. Shorter, planned attendance is usually a better trade than either enduring or avoiding.",
            "Planning one meal at a time — which is what the Plan tab is for — is more achievable than solving meals in general."
        ]),
        TELearnCard(id: "l_masking", title: "How masking sound actually helps", section: "Living with it", paragraphs: [
            "A trigger stands out most against silence. Raising the background level slightly reduces the contrast, which is why a fan can help more than its volume suggests.",
            "Continuous, featureless sound works better than music with structure, because structure attracts attention in its own right.",
            "Start it before the trigger begins where you can. Introducing masking mid-episode is noticeably less effective.",
            "Keep it low. The goal is a floor you stop noticing within a minute, not drowning the room out — and loud continuous sound in headphones carries its own risks to your hearing."
        ]),
        TELearnCard(id: "l_volume", title: "Protecting your hearing", section: "Living with it", paragraphs: [
            "If you use masking sound through headphones for long stretches, volume matters. Long exposure at high levels carries a real risk of hearing damage.",
            "Set the level while the room is quiet, before the trigger starts. Levels chosen mid-episode tend to be far too high.",
            "If you have to raise your voice to be heard over your own masking sound, it is too loud.",
            "This app starts every preset at a low level and ramps in gently for that reason. An audiologist can advise on safe long-term use."
        ]),
        TELearnCard(id: "l_avoidance", title: "Avoidance — the honest trade-off", section: "Living with it", paragraphs: [
            "Avoiding a situation works immediately, which is exactly why it is so easy to keep doing.",
            "The cost accumulates quietly: fewer meals with people, fewer invitations, a narrower life, and often a stronger reaction when the situation finally cannot be avoided.",
            "That does not mean you should push through everything. It means the choice is worth making deliberately rather than by default.",
            "Rearranging a situation so you can attend — different seat, shorter stay, stated end time — is usually a better trade than either enduring or skipping it."
        ]),
        TELearnCard(id: "l_recovery", title: "Recovery takes longer than you think", section: "Living with it", paragraphs: [
            "The physical surge outlasts the sound. People commonly describe fifteen to forty minutes before they feel level again.",
            "Decisions made during that window — about the person, the evening, the relationship — are made on a raised baseline and are worth deferring.",
            "Movement, cold water and a change of room all shorten it for many people. Replaying the episode lengthens it.",
            "The journal records recovery time separately from duration, so you can find out what your own typical figure is instead of guessing."
        ]),
        TELearnCard(id: "l_secondwave", title: "The second wave: shame", section: "Living with it", paragraphs: [
            "Many people describe a second reaction that arrives after the first: guilt about the anger, or shame at having reacted to someone they love.",
            "This is frequently the more damaging of the two, because it lasts longer and it attaches to your idea of yourself rather than to a sound.",
            "The reaction was involuntary. If you were sharp with somebody, that specific thing can be repaired without accepting that having the reaction was a failing.",
            "There is a repair script in the Toolkit for exactly this."
        ])
    ]

    // MARK: - Other people

    static let others: [TELearnCard] = [
        TELearnCard(id: "l_sceptic", title: "Talking to a skeptical family member", section: "Other people", paragraphs: [
            "Being told you are oversensitive, rude, or doing it for attention is one of the most commonly reported experiences, and it is exhausting on top of the thing itself.",
            "Describing the physical response — heart rate, muscle tension, the urge to escape — usually lands better than describing how annoying the sound is, because annoyance is something everyone thinks they can compare against.",
            "Ask for one specific, small change rather than for understanding. Understanding is optional; the seat arrangement is not.",
            "If someone continues to dismiss it after a clear explanation, you are not obliged to keep making the case. There is a script in the Toolkit for one clean attempt."
        ]),
        TELearnCard(id: "l_partner", title: "Telling a partner", section: "Other people", paragraphs: [
            "Telling somebody early is generally easier than explaining afterwards why you went cold at dinner.",
            "The most useful things to convey are: it is involuntary, it is not about them, and here is the one thing that helps.",
            "A pre-agreed signal removes the need to have the conversation in front of other people, which is where most of the friction happens.",
            "Being believed is the thing most people say they need. A partner does not have to fix anything."
        ]),
        TELearnCard(id: "l_child", title: "Supporting a child with it", section: "Other people", paragraphs: [
            "Children often cannot name what is happening, and it may present as sudden anger at the table, refusing to eat with the family, or leaving abruptly.",
            "Believing them first matters more than any technique. Being told it is nothing is what most adults with misophonia remember about their childhood.",
            "Practical steps: let them change seats, allow leaving the table without it being a punishment, add background sound at meals, and do not require them to explain each time.",
            "If it is affecting school, sleep or friendships, ask their doctor about a referral. Bring a written record of when it happens."
        ]),
        TELearnCard(id: "l_youAreTheTrigger", title: "If you are somebody's trigger", section: "Other people", paragraphs: [
            "If someone has told you that a sound you make sets off a strong reaction, the most useful response is to believe them without needing to understand it.",
            "It is not a criticism of you, and their reaction is not something they chose or can talk themselves out of.",
            "Small accommodations go a long way: agreeing where people sit, background sound at meals, not taking it personally when they step out.",
            "Asking them what specifically helps is better than guessing, and better than deciding it must be nothing."
        ]),
        TELearnCard(id: "l_disclose", title: "How much to disclose", section: "Other people", paragraphs: [
            "You are not obliged to explain a medical-sounding reason to get a different seat, a quiet room, or a table by the wall.",
            "\"I'm sensitive to noise\" is usually enough and is far easier to say than a full account.",
            "Save the longer explanation for the small number of people whose behavior you actually need to change.",
            "Disclosure at work is a judgment call about your specific workplace. Framing a request around output rather than health keeps that door open."
        ]),
        TELearnCard(id: "l_showprofile", title: "Showing someone your trigger profile", section: "Other people", paragraphs: [
            "The heat grid in the Triggers tab is designed to be shown to another person.",
            "A picture of which sounds rate where is often more persuasive than a conversation, because it is specific and it is obviously not improvised.",
            "It also lets somebody see what is not a trigger, which makes the whole thing look less like a general complaint about noise.",
            "Everything in this app stays on your device unless you choose to show it to somebody."
        ])
    ]

    // MARK: - Support and evidence

    static let support: [TELearnCard] = [
        TELearnCard(id: "l_evidence", title: "What people report using — and the honest state of the evidence", section: "Support and evidence", paragraphs: [
            "Approaches people commonly report using include talking therapies such as cognitive behavioral approaches, sound-based management through audiology, and general stress and sleep management.",
            "Published studies exist and some report meaningful improvement, but sample sizes are often small, definitions differ between studies, and there is no established standard approach.",
            "Nobody can currently promise you a cure, and this app makes no claim to help with anything beyond preparation, self-tracking and coping.",
            "Be cautious with anything sold with a guarantee, and cautious with confident claims in either direction."
        ]),
        TELearnCard(id: "l_professional", title: "When to see a professional", section: "Support and evidence", paragraphs: [
            "Reasonable reasons to seek professional help: it is affecting your sleep, your work or study, your relationships, or you are avoiding significant parts of your life.",
            "Also worth an appointment: any actual pain from sound, new or one-sided tinnitus, hearing changes, or persistent low mood.",
            "Useful directions include an audiologist, a psychologist or a general practitioner who can refer onwards. Not every clinician will know the term, which is not a reason to stop.",
            "Take a written summary with you. There is a script for the conversation in the Toolkit."
        ]),
        TELearnCard(id: "l_exposure", title: "Graded exposure — what it is and the caveats", section: "Support and evidence", paragraphs: [
            "Graded exposure means approaching a difficult stimulus in small, controlled steps rather than all at once, staying with each step until it settles.",
            "It is used for a range of difficulties and some people with misophonia report that a gentle, self-paced version helps. Others report that it does not, or that it makes things worse.",
            "It is generally best done with the support of a therapist, particularly if it is distressing. It should never feel like being pushed.",
            "The optional ladder in this app is deliberately gentle, entirely opt-in, has a stop control on every screen, and records no streaks. If a step is distressing, stopping is the correct response, not a failure."
        ]),
        TELearnCard(id: "l_notapp", title: "What this app is not", section: "Support and evidence", paragraphs: [
            "Trigger Ease is a self-tracking and preparation tool. It is not a medical device and it does not provide medical advice.",
            "It cannot tell you whether you have misophonia or anything else, and it does not attempt to.",
            "Nothing in it replaces an assessment by a qualified clinician — an audiologist, a psychologist or a physician.",
            "If you are in crisis or your safety is at risk, contact your local emergency services or a crisis line rather than an app."
        ]),
        TELearnCard(id: "l_data", title: "Where your data lives", section: "Support and evidence", paragraphs: [
            "Everything you enter — plans, episodes, ratings, notes — is stored only on this device.",
            "There is no account, no sync, no analytics, and nothing you enter is ever uploaded. The app makes one check when it launches, and the Privacy Policy page is fetched from the web when you open it.",
            "Reset all data in Settings erases everything permanently. The app keeps no copy of its own, but the file sits in the app's storage on this device, so a device or iCloud backup taken earlier may still contain one.",
            "The optional privacy lock adds a device authentication check when the app opens."
        ]),
        TELearnCard(id: "l_nonotifications", title: "Why there are no notifications", section: "Support and evidence", paragraphs: [
            "This app will never send you a push notification, and it contains no notification code at all.",
            "An alert about a trigger is itself an unwanted intrusion, and daily prompts encourage the kind of monitoring that tends to make things worse.",
            "Plans with an upcoming date appear in the app when you open it. Nothing chases you.",
            "There are no streaks, no scores and nothing to keep up with."
        ])
    ]
}
