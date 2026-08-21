import Foundation

// The trigger catalogue. Descriptions are matter-of-fact: what the sound is, and what tends to
// make it worse or easier. Nothing here calls the reaction an overreaction.

enum TETriggerCatalog {

    static let all: [TETrigger] = oral + nasal + motion + environmental + vocal + visual

    static func byID(_ id: String) -> TETrigger? {
        lookup[id]
    }

    private static let lookup: [String: TETrigger] = {
        var map: [String: TETrigger] = [:]
        for trigger in all { map[trigger.id] = trigger }
        return map
    }()

    static func inClass(_ triggerClass: TETriggerClass) -> [TETrigger] {
        all.filter { $0.triggerClass == triggerClass }
    }

    static func search(_ query: String) -> [TETrigger] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return all }
        return all.filter { $0.name.lowercased().contains(q) || $0.detail.lowercased().contains(q) }
    }

    // MARK: - Oral

    static let oral: [TETrigger] = [
        TETrigger(id: "chewing", name: "Chewing", triggerClass: .oral,
                  detail: "The soft, wet, rhythmic sound of somebody chewing food. The most commonly reported trigger of all, and the one people are least willing to hear a complaint about."),
        TETrigger(id: "crunchy", name: "Crunchy chewing", triggerClass: .oral,
                  detail: "Chips, apples, toast, raw carrot. The sharp attack of each bite makes it harder to habituate than soft chewing, and it carries across a room."),
        TETrigger(id: "gum", name: "Gum chewing", triggerClass: .oral,
                  detail: "Continuous, unhurried and open-ended — unlike a meal it has no obvious finish line, which is often what makes it unbearable."),
        TETrigger(id: "lipsmack", name: "Lip smacking", triggerClass: .oral,
                  detail: "The small pop of lips parting between bites or words. Quiet in absolute terms, which is exactly why other people insist it cannot be a problem."),
        TETrigger(id: "slurping", name: "Slurping", triggerClass: .oral,
                  detail: "Drawing liquid in over the lip — soup, coffee, tea. In some places it is polite, which can make asking for it to stop socially awkward."),
        TETrigger(id: "swallow", name: "Swallowing", triggerClass: .oral,
                  detail: "The gulp at the back of the throat. Usually only audible when the room is quiet, so it tends to hit hardest at night or in an exam hall."),
        TETrigger(id: "teethsuck", name: "Teeth sucking", triggerClass: .oral,
                  detail: "Working food out from between teeth with the tongue. Repetitive, unconscious, and typically goes on for minutes after a meal has ended."),
        TETrigger(id: "jawclick", name: "Jaw clicking", triggerClass: .oral,
                  detail: "A click or pop from somebody's jaw joint as they chew. Irregular timing means you cannot brace for it."),
        TETrigger(id: "openmouth", name: "Eating with an open mouth", triggerClass: .oral,
                  detail: "Chewing with the lips apart, which removes the only muffling there is. Frequently the specific thing a family argument is really about."),
        TETrigger(id: "cutleryteeth", name: "Cutlery scraping teeth", triggerClass: .oral,
                  detail: "A fork or spoon dragged against enamel. Even people without misophonia often flinch at this one, which occasionally makes it easier to explain."),
        TETrigger(id: "straw", name: "Straw noises", triggerClass: .oral,
                  detail: "The rattle of a straw in a lid, and the long dry pull at the bottom of a cup. Common in cinemas and cafés, where you cannot move far."),
        TETrigger(id: "icecrunch", name: "Ice crunching", triggerClass: .oral,
                  detail: "Chewing ice cubes. Loud, hard-edged and unpredictable in rhythm — a frequent problem in restaurants and on long car journeys."),
        TETrigger(id: "cerealmilk", name: "Cereal and milk", triggerClass: .oral,
                  detail: "Spoon, bowl, milk and crunch layered together. A daily breakfast trigger in shared kitchens, arriving before you are properly awake."),
        TETrigger(id: "chipbag", name: "Eating from a bag", triggerClass: .oral,
                  detail: "Hand into a foil bag, then chewing. The bag and the mouth alternate, so there is no gap to recover in."),
        TETrigger(id: "kissing", name: "Kissing sounds", triggerClass: .oral,
                  detail: "Wet mouth contact sounds, including on television. Often reported as intensely aversive and rarely mentioned out loud."),
        TETrigger(id: "toothbrush", name: "Toothbrushing", triggerClass: .oral,
                  detail: "Bristles, foam and spitting through a thin bathroom wall. A shared-home trigger, twice a day, at fixed times."),
        TETrigger(id: "burping", name: "Burping", triggerClass: .oral,
                  detail: "Sudden and involuntary on their side, but the surprise is part of what makes the reaction sharp on yours.")
    ]

    // MARK: - Nasal and throat

    static let nasal: [TETrigger] = [
        TETrigger(id: "sniffing", name: "Sniffing", triggerClass: .nasal,
                  detail: "A repeated wet inhale through a blocked nose. It follows no rhythm you can predict, and it can go on for an entire winter."),
        TETrigger(id: "snorting", name: "Snorting", triggerClass: .nasal,
                  detail: "A harder, deeper version of sniffing that pulls from the back of the throat."),
        TETrigger(id: "throatclear", name: "Throat clearing", triggerClass: .nasal,
                  detail: "A short scrape repeated every minute or two. Often a habit rather than a need, which is why it persists after a cold has gone."),
        TETrigger(id: "coughing", name: "Coughing", triggerClass: .nasal,
                  detail: "Hard to raise with anyone, because they are ill and you are not supposed to mind. That double bind is part of the load."),
        TETrigger(id: "loudbreath", name: "Loud breathing", triggerClass: .nasal,
                  detail: "Audible air moving in and out at rest. Common in quiet rooms — libraries, exam halls, shared beds."),
        TETrigger(id: "mouthbreath", name: "Mouth breathing", triggerClass: .nasal,
                  detail: "Breathing through an open mouth, often with a faint rasp. Frequently reported as a trigger during shared sleep."),
        TETrigger(id: "nosewhistle", name: "Nose whistling", triggerClass: .nasal,
                  detail: "A thin high tone on each breath. Very quiet, very precise in pitch, and almost impossible to un-hear once noticed."),
        TETrigger(id: "snoring", name: "Snoring", triggerClass: .nasal,
                  detail: "Loud, cyclical and nightly. It combines a trigger with sleep loss, which is why it wears people down faster than most."),
        TETrigger(id: "nosewipe", name: "Wiping or rubbing the nose", triggerClass: .nasal,
                  detail: "The dry drag of a sleeve or hand across the nose, usually paired with sniffing."),
        TETrigger(id: "hiccup", name: "Hiccups", triggerClass: .nasal,
                  detail: "Sharp and involuntary on a rough interval, so you spend the gaps waiting for the next one."),
        TETrigger(id: "yawnsound", name: "Vocalised yawning", triggerClass: .nasal,
                  detail: "A yawn released with a groan or sigh. Contagious in a group, so it often repeats around a table."),
        TETrigger(id: "sighing", name: "Repeated sighing", triggerClass: .nasal,
                  detail: "A long audible exhale, often read as a comment on the room, which can add an emotional charge on top of the sound.")
    ]

    // MARK: - Repetitive motion / percussive

    static let motion: [TETrigger] = [
        TETrigger(id: "penclick", name: "Pen clicking", triggerClass: .motion,
                  detail: "A hard plastic click at irregular intervals. Classic classroom, meeting-room and waiting-room trigger."),
        TETrigger(id: "keyboard", name: "Keyboard typing", triggerClass: .motion,
                  detail: "Mechanical keys, or one very heavy typist among quiet ones. Open-plan offices make this nearly unavoidable."),
        TETrigger(id: "mouseclick", name: "Mouse clicking", triggerClass: .motion,
                  detail: "A single sharp click, often in bursts. Quiet enough that colleagues genuinely cannot hear it themselves."),
        TETrigger(id: "foottap", name: "Foot tapping", triggerClass: .motion,
                  detail: "A heel or toe against a hard floor, sometimes transmitted through the floor into your own chair."),
        TETrigger(id: "kneebounce", name: "Knee bouncing", triggerClass: .motion,
                  detail: "Rapid vertical movement that you often feel through a shared bench or table before you hear it."),
        TETrigger(id: "fingerdrum", name: "Finger drumming", triggerClass: .motion,
                  detail: "Fingertips rolling across a desk. Rhythmic and unconscious, and it usually restarts within seconds of stopping."),
        TETrigger(id: "nailtap", name: "Nail tapping", triggerClass: .motion,
                  detail: "Long nails on a table, a glass or a phone screen. Higher and sharper than fingertip drumming."),
        TETrigger(id: "nailclip", name: "Nail clipping", triggerClass: .motion,
                  detail: "A hard snap with a random gap between each one. Widely reported as intolerable even by people with no other triggers."),
        TETrigger(id: "hairtwirl", name: "Hair twirling", triggerClass: .motion,
                  detail: "Faint friction of hair being wound and released, usually near your ear on a train or in a lecture."),
        TETrigger(id: "pentap", name: "Pen tapping", triggerClass: .motion,
                  detail: "The barrel of a pen struck against a desk or notebook, often keeping time with music you cannot hear."),
        TETrigger(id: "legshake", name: "Shaking a shared surface", triggerClass: .motion,
                  detail: "Movement transmitted through a table, sofa or bed. Felt as much as heard, which makes masking useless."),
        TETrigger(id: "cracking", name: "Knuckle or joint cracking", triggerClass: .motion,
                  detail: "A dull pop repeated across every finger in turn, so it lasts far longer than a single sound."),
        TETrigger(id: "cliketiquette", name: "Phone keyboard clicks", triggerClass: .motion,
                  detail: "Synthetic key clicks left switched on in public. Small, sharp and endlessly repeated."),
        TETrigger(id: "spinner", name: "Fidget object rattle", triggerClass: .motion,
                  detail: "Spinners, clickers, coins or keys worked in one hand. Intended to be soothing for the user and rarely for anyone else."),
        TETrigger(id: "papershuffle", name: "Paper shuffling", triggerClass: .motion,
                  detail: "Repeated straightening and riffling of a stack of paper, common in meetings and exam halls."),
        TETrigger(id: "scratching", name: "Scratching skin or fabric", triggerClass: .motion,
                  detail: "A dry repetitive rasp. Very quiet, close-range, and often paired with movement in your field of view.")
    ]

    // MARK: - Environmental

    static let environmental: [TETrigger] = [
        TETrigger(id: "basswall", name: "Bass through a wall", triggerClass: .environmental,
                  detail: "Only the low end survives the wall, so you get a pulse with no music attached. Ordinary earplugs barely touch it."),
        TETrigger(id: "clock", name: "Ticking clock", triggerClass: .environmental,
                  detail: "Perfectly regular, which sounds like it should help and usually does the opposite once you have locked onto it."),
        TETrigger(id: "drip", name: "Dripping tap", triggerClass: .environmental,
                  detail: "An irregular drip in a quiet room. The gap between drips is where the tension builds."),
        TETrigger(id: "fridge", name: "Fridge hum", triggerClass: .environmental,
                  detail: "A low continuous hum that cycles on and off. Often noticed most at the moment it stops."),
        TETrigger(id: "tvnextroom", name: "TV in another room", triggerClass: .environmental,
                  detail: "Muffled speech and music with the words removed. The brain keeps trying to resolve it into language."),
        TETrigger(id: "wrapper", name: "Plastic wrapper crinkling", triggerClass: .environmental,
                  detail: "Sharp, unpredictable and high frequency. Cinemas, trains and quiet carriages are the usual settings."),
        TETrigger(id: "styrofoam", name: "Styrofoam squeak", triggerClass: .environmental,
                  detail: "The squeal of polystyrene rubbed against itself or against cardboard."),
        TETrigger(id: "cutleryplate", name: "Cutlery on plates", triggerClass: .environmental,
                  detail: "Metal scraping ceramic. In a busy restaurant it comes from every direction at once."),
        TETrigger(id: "dogbark", name: "Barking dog", triggerClass: .environmental,
                  detail: "Loud, sudden and repeated, often from a neighboring property where you have no control at all."),
        TETrigger(id: "doglick", name: "Dog licking", triggerClass: .environmental,
                  detail: "Wet, close-range and unhurried. Frequently reported by people who otherwise love the animal, which is its own kind of difficult."),
        TETrigger(id: "leafblower", name: "Leaf blower", triggerClass: .environmental,
                  detail: "A broadband roar that changes pitch as it sweeps, so it never settles into background."),
        TETrigger(id: "caralarm", name: "Car alarm", triggerClass: .environmental,
                  detail: "Designed to be impossible to ignore, and it succeeds. There is rarely anything you can do but wait."),
        TETrigger(id: "keys", name: "Keys jangling", triggerClass: .environmental,
                  detail: "Metallic, bright and tied to somebody walking, so it moves through the room."),
        TETrigger(id: "crisppacket", name: "Rustling chip bag", triggerClass: .environmental,
                  detail: "The bag on its own, with no chewing — foil handled slowly, which is often worse than handling it quickly. Common in movie theaters and lecture halls. The oral trigger \"Eating from a bag\" is the one for bag and chewing together."),
        TETrigger(id: "airconhum", name: "Air conditioning hum", triggerClass: .environmental,
                  detail: "A steady mechanical drone in an office or hotel room, sometimes with a rattle riding on top of it."),
        TETrigger(id: "flapping", name: "Flapping or ticking fabric", triggerClass: .environmental,
                  detail: "A blind cord, a loose flag or a curtain in a draught, tapping on no fixed schedule."),
        TETrigger(id: "reversing", name: "Reversing beeper", triggerClass: .environmental,
                  detail: "A hard electronic beep at a fixed interval, carrying a long way across a street or site."),
        TETrigger(id: "phonevibrate", name: "Phone vibrating on a hard surface", triggerClass: .environmental,
                  detail: "A rattling buzz that repeats every time a message lands, and you cannot silence somebody else's phone."),
        TETrigger(id: "footsteps", name: "Footsteps overhead", triggerClass: .environmental,
                  detail: "Heels or heavy walking through a ceiling. Impact noise travels through structure, so soft furnishings barely help."),
        TETrigger(id: "doorslam", name: "Door slamming", triggerClass: .environmental,
                  detail: "A single loud impact, unpredictable in timing, that often leaves an adrenaline spike behind for several minutes."),
        TETrigger(id: "cutlerydrawer", name: "Cutlery drawer", triggerClass: .environmental,
                  detail: "A drawer of loose metal being rummaged through in a shared kitchen."),
        TETrigger(id: "buzzinglight", name: "Buzzing light or transformer", triggerClass: .environmental,
                  detail: "A thin mains hum from a fitting or a charger. Very quiet, and effectively permanent.")
    ]

    // MARK: - Vocal

    static let vocal: [TETrigger] = [
        TETrigger(id: "whispering", name: "Whispering", triggerClass: .vocal,
                  detail: "Breath-heavy speech with the pitch removed. Two rows back in a cinema, it can be worse than talking."),
        TETrigger(id: "whistling", name: "Whistling", triggerClass: .vocal,
                  detail: "A pure high tone that cuts through everything and usually loops a few bars over and over."),
        TETrigger(id: "humming", name: "Humming", triggerClass: .vocal,
                  detail: "Tuneless and continuous, often stopping the instant you look up and restarting a minute later."),
        TETrigger(id: "verbaltic", name: "A repeated verbal tic", triggerClass: .vocal,
                  detail: "A filler word or a small vocal habit repeated every sentence. Once counted, it cannot be uncounted."),
        TETrigger(id: "specificlaugh", name: "A specific laugh", triggerClass: .vocal,
                  detail: "One person's laugh in particular. Highly specific triggers like this are extremely common and rarely admitted to."),
        TETrigger(id: "speakerphone", name: "Phone speaker audio in public", triggerClass: .vocal,
                  detail: "Compressed video or a call played out loud on a train or in a waiting room."),
        TETrigger(id: "headphoneleak", name: "Headphone leakage", triggerClass: .vocal,
                  detail: "Only the treble escapes, so you get a thin tinny rhythm with nothing underneath it."),
        TETrigger(id: "loudvoice", name: "One voice carrying above the rest", triggerClass: .vocal,
                  detail: "A single voice pitched above the room in an office or café, so your attention keeps snapping to it."),
        TETrigger(id: "babbling", name: "Repetitive child vocalising", triggerClass: .vocal,
                  detail: "A repeated sound or phrase from a young child. Often carries guilt with it, which makes it heavier to log."),
        TETrigger(id: "singingalong", name: "Singing along", triggerClass: .vocal,
                  detail: "Partial, off-key singing over music you can hear only faintly."),
        TETrigger(id: "throatsinging", name: "Vocal fry", triggerClass: .vocal,
                  detail: "A creaky low rasp at the end of sentences. Very quiet and very specific in texture."),
        TETrigger(id: "shushing", name: "Shushing", triggerClass: .vocal,
                  detail: "A long hiss of breath. Ironically often produced in an attempt to make a room quieter.")
    ]

    // MARK: - Visual (misokinesia)

    static let visual: [TETrigger] = [
        TETrigger(id: "legjiggle", name: "Leg jiggling", triggerClass: .visual,
                  detail: "Rapid repetitive movement at the edge of your vision. The single most reported visual trigger, and one that needs no sound at all."),
        TETrigger(id: "fidgeting", name: "General fidgeting", triggerClass: .visual,
                  detail: "Constant small adjustments — a sleeve, a ring, a phone turned over and back."),
        TETrigger(id: "repeatgesture", name: "A repeated gesture", triggerClass: .visual,
                  detail: "One movement repeated at a set interval, such as pushing hair back or adjusting glasses."),
        TETrigger(id: "seenchewing", name: "Chewing seen, not heard", triggerClass: .visual,
                  detail: "A jaw moving across a room or on a silent screen. Enough on its own for many people, which is exactly why sound-only trigger lists fall short."),
        TETrigger(id: "pentwirl", name: "Pen twirling", triggerClass: .visual,
                  detail: "Continuous rotation in somebody's hand within your field of view."),
        TETrigger(id: "footwag", name: "Foot wagging", triggerClass: .visual,
                  detail: "A crossed leg swinging in a steady rhythm, usually across a table from you."),
        TETrigger(id: "screenflicker", name: "Repetitive on-screen motion", triggerClass: .visual,
                  detail: "A looping animation or an auto-playing video in the corner of a page or a public screen."),
        TETrigger(id: "hairtouch", name: "Repeated hair touching", triggerClass: .visual,
                  detail: "Hands returning to the same place over and over, sometimes with a faint sound attached."),
        TETrigger(id: "rocking", name: "Rocking or swaying", triggerClass: .visual,
                  detail: "Slow whole-body movement in a chair. Large in your visual field, so it is difficult to look past.")
    ]
}
