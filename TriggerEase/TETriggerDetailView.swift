import SwiftUI

struct TETriggerDetailView: View {
    let triggerID: String
    var onBack: (() -> Void)?

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode

    private var trigger: TETrigger? { TETriggerCatalog.byID(triggerID) }

    var body: some View {
        Group {
            if let trigger = trigger {
                content(trigger)
            } else {
                TEPage(title: "Trigger", onBack: back) {
                    TEEmptyState(glyph: .triggers, title: "Not found",
                                 message: "This trigger is not in the catalogue.")
                }
            }
        }
    }

    private func back() {
        if let onBack = onBack {
            onBack()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func content(_ trigger: TETrigger) -> some View {
        let profile = TEAnalytics.profile(for: triggerID, episodes: store.episodes)
        let rating = store.rating(for: triggerID)

        return TEPage(title: trigger.name,
                      subtitle: trigger.triggerClass.title,
                      onBack: back) {

            TECard {
                Text(trigger.detail)
                    .font(TEType.body(14.5))
                    .foregroundColor(TEPalette.ink)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                TEQuietRule()
                Text(trigger.triggerClass.blurb)
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            TESectionHeader(title: "Your rating")
            TECard {
                TEScalePicker(value: rating ?? 0,
                              lowLabel: rating == nil ? "Not rated" : "Fine",
                              highLabel: "Unbearable") { store.setRating($0, for: triggerID) }
                if rating != nil {
                    Button(action: { store.setRating(nil, for: triggerID) }) {
                        HStack(spacing: 6) {
                            TEGlyph(kind: .close, size: 13, color: TEPalette.inkFaint)
                            Text("Clear rating")
                                .font(TEType.body(12))
                                .foregroundColor(TEPalette.inkFaint)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            journalSection(profile)
            techniqueSection
            ladderSection
        }
    }

    // MARK: - Journal

    private func journalSection(_ profile: TEAnalytics.TriggerProfile) -> some View {
        Group {
            TESectionHeader(title: "In your journal", note: "\(profile.count) \(profile.count == 1 ? "entry" : "entries")")
            if profile.count == 0 {
                TEFootnote(text: "You have not logged this one yet. Logging it a few times is what fills in the sections below.")
            } else {
                TECard {
                    HStack(alignment: .top, spacing: 16) {
                        if let mean = profile.meanIntensity {
                            TEDial(value: mean, maxValue: 10, caption: "typical\nintensity", size: 74,
                                   tint: TEPalette.intensity(Int(mean.rounded())))
                        }
                        VStack(alignment: .leading, spacing: 7) {
                            if let recovery = profile.meanRecovery {
                                statLine(label: "Typical recovery",
                                         value: recovery > 0 ? "about \(Int(recovery.rounded())) min" : "—")
                            }
                            if let last = profile.lastSeen {
                                statLine(label: "Last logged", value: TEFormat.shortDate.string(from: last))
                            }
                            statLine(label: "Entries", value: "\(profile.count)")
                        }
                        Spacer(minLength: 0)
                    }
                    if !profile.topPlaces.isEmpty {
                        TEQuietRule()
                        Text("Where it happens")
                            .font(TEType.medium(12))
                            .foregroundColor(TEPalette.inkFaint)
                        ForEach(profile.topPlaces) { place in
                            TEBarRow(label: place.label, value: place.mean, maxValue: 10,
                                     caption: "\(place.count) \(place.count == 1 ? "entry" : "entries") · mean \(TEFormat.decimal(place.mean))",
                                     tint: TEPalette.clay)
                        }
                    }
                    if !profile.topRoles.isEmpty {
                        TEQuietRule()
                        Text("Who is usually there")
                            .font(TEType.medium(12))
                            .foregroundColor(TEPalette.inkFaint)
                        ForEach(profile.topRoles) { role in
                            TEBarRow(label: role.label, value: role.mean, maxValue: 10,
                                     caption: "\(role.count) \(role.count == 1 ? "entry" : "entries") · mean \(TEFormat.decimal(role.mean))",
                                     tint: TEPalette.mossDeep)
                        }
                    }
                    if profile.count < TEAnalytics.minimumSamples {
                        TENotEnoughData(needed: TEAnalytics.minimumSamples, have: profile.count)
                    }
                }
            }
        }
    }

    private func statLine(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(TEType.body(11))
                .foregroundColor(TEPalette.inkFaint)
            Text(value)
                .font(TEType.medium(14))
                .foregroundColor(TEPalette.ink)
        }
    }

    // MARK: - Techniques

    private var techniqueSection: some View {
        Group {
            let ranked = TEPlanEngine.techniquesFor(triggerID: triggerID, plans: store.plans)
            TESectionHeader(title: "Techniques against this one")
            if ranked.isEmpty {
                TEFootnote(text: "Nothing yet. Add this trigger to a plan, score the plan afterwards, and the techniques you used against it get ranked here.")
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

    // MARK: - Ladder

    private var ladderSection: some View {
        Group {
            TESectionHeader(title: "Graded ladder", note: "optional")
            TECard(background: TEPalette.claySoft.opacity(0.4), border: TEPalette.clay.opacity(0.35)) {
                Text("Entirely optional and entirely self-paced")
                    .font(TEType.medium(14))
                    .foregroundColor(TEPalette.clayDeep)
                Text("A short sequence of small steps, from thinking about the sound through to hearing it unmasked. Every step has a stop control, nothing is timed against you, and there are no streaks. Graded exposure is best done with a therapist's support if it is distressing — if a step is hard, stopping is the right answer, not a failure.")
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.clayDeep.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
                let reached = store.ladderReached(for: triggerID)
                if reached >= 0 {
                    Text("You have completed step \(reached + 1) of \(TELadder.steps.count) for this trigger.")
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.clayDeep)
                }
                NavigationLink(destination: TELadderView(triggerID: triggerID)) {
                    HStack(spacing: 8) {
                        TEGlyph(kind: .ladder, size: 16, color: TEPalette.clayDeep)
                        Text(reached >= 0 ? "Open the ladder" : "Read more and decide")
                            .font(TEType.medium(14.5))
                            .foregroundColor(TEPalette.clayDeep)
                        Spacer(minLength: 0)
                        TEGlyph(kind: .chevronRight, size: 14, color: TEPalette.clayDeep.opacity(0.7))
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(TEPalette.clayDeep.opacity(0.4), lineWidth: 1.2)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
