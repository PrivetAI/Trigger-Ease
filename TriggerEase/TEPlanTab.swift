import SwiftUI

struct TEPlanTab: View {
    @EnvironmentObject private var store: TEStore

    var body: some View {
        TEPage(title: "Plan",
               subtitle: "Decide what you will do before you are in the room.") {

            TEAbsorbArt(width: max(120, TEMetrics.screenWidth - 36), height: TEMetrics.isCompactHeight ? 72 : 88)
                .padding(.bottom, 2)

            NavigationLink(destination: TENewPlanView()) {
                HStack(spacing: 10) {
                    TEGlyph(kind: .plus, size: 19, color: TEPalette.card, weight: 2.0)
                    Text("Build a plan")
                        .font(TEType.title(16))
                        .foregroundColor(TEPalette.card)
                    Spacer(minLength: 0)
                    TEGlyph(kind: .chevronRight, size: 16, color: TEPalette.card.opacity(0.8))
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(TEPalette.moss)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            if store.plans.isEmpty {
                emptyState
            } else {
                needsScoringSection
                upcomingSection
                librarySection
            }

            TESectionHeader(title: "What works for you")
            TENavRow(title: "Strategy ranking",
                     detail: store.totalRuns == 0
                        ? "Nothing scored yet. Score a plan and the ranking starts building."
                        : "Built from \(store.totalRuns) scored \(store.totalRuns == 1 ? "run" : "runs").",
                     leading: { TERowBadge(glyph: .chart, tint: TEPalette.clay) },
                     destination: { TEStrategyView() })

            TENavRow(title: "Situation templates",
                     detail: "\(TESituationTemplates.all.count) situations with seating, exit lines and starting techniques.",
                     leading: { TERowBadge(glyph: .seat) },
                     destination: { TETemplateLibraryView() })

            TEDisclaimerCard(compact: true)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            TEEmptyState(glyph: .plan,
                         title: "No plans yet",
                         message: "A plan is one page you can open in the moment: where you will sit, what you will have running, two techniques ready, and the exact sentence you will say if you need to leave.\n\nAfterwards you score it, and the app starts learning which of those actually work for you.")
        }
    }

    private var needsScoringSection: some View {
        Group {
            let pending = store.plansNeedingScore
            if !pending.isEmpty {
                TESectionHeader(title: "Ready to score", note: "\(pending.count)")
                ForEach(pending.prefix(4)) { plan in
                    TENavRow(title: plan.name,
                             detail: "\(TEFormat.dateTime.string(from: plan.scheduledAt)) — how did it go?",
                             badge: "score",
                             leading: { TERowBadge(glyph: .edit, tint: TEPalette.clay) },
                             destination: { TEPlanScoreView(planID: plan.id) })
                }
            }
        }
    }

    private var upcomingSection: some View {
        Group {
            let upcoming = store.upcomingPlans
            if !upcoming.isEmpty {
                TESectionHeader(title: "Coming up", note: "\(upcoming.count)")
                ForEach(upcoming.prefix(6)) { plan in
                    TENavRow(title: plan.name,
                             detail: upcomingDetail(plan),
                             leading: { TERowBadge(glyph: .clock) },
                             destination: { TEPlanDetailView(planID: plan.id) })
                }
            }
        }
    }

    private func upcomingDetail(_ plan: TEPlan) -> String {
        let days = teDaysBetween(Date(), plan.scheduledAt)
        let when: String
        if days == 0 { when = "Today at \(TEFormat.clock.string(from: plan.scheduledAt))" }
        else if days == 1 { when = "Tomorrow at \(TEFormat.clock.string(from: plan.scheduledAt))" }
        else { when = TEFormat.dateTime.string(from: plan.scheduledAt) }
        let template = TESituationTemplates.byID(plan.templateID)?.name ?? "Custom"
        return "\(when) · \(template)"
    }

    private var librarySection: some View {
        Group {
            let library = store.repeatablePlans
            if !library.isEmpty {
                TESectionHeader(title: "All plans", note: "\(library.count)")
                ForEach(library) { plan in
                    TENavRow(title: plan.name,
                             detail: TEPlanEngine.trendSentence(for: plan),
                             leading: { TERowBadge(glyph: plan.runs.isEmpty ? .plan : .repeatArrow,
                                                   tint: plan.runs.isEmpty ? TEPalette.moss : TEPalette.clay) },
                             destination: { TEPlanDetailView(planID: plan.id) })
                }
            }
        }
    }
}

// MARK: - Template library

struct TETemplateLibraryView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        TEPage(title: "Situations",
               subtitle: "Fourteen situations people most often need a plan for.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {
            ForEach(TESituationTemplates.all) { template in
                TENavRow(title: template.name,
                         detail: template.blurb,
                         leading: { TERowBadge(glyph: glyph(for: template.id)) },
                         destination: { TETemplateDetailView(templateID: template.id) })
            }
        }
    }

    private func glyph(for id: String) -> TEGlyphKind {
        switch id {
        case "familymeal", "restaurant", "sharedhome": return .seat
        case "openplan", "studyspace", "exam": return .plan
        case "cinema", "videocall": return .grid
        case "carjourney", "transport", "flight": return .exit
        case "sharedbedroom": return .timer
        case "gym": return .repeatArrow
        default: return .place
        }
    }
}

struct TETemplateDetailView: View {
    let templateID: String
    @Environment(\.presentationMode) private var presentationMode

    private var template: TESituationTemplate {
        TESituationTemplates.byID(templateID) ?? TESituationTemplates.blank
    }

    var body: some View {
        TEPage(title: template.name,
               subtitle: template.blurb,
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TESectionHeader(title: "Seating and position")
            TECard {
                ForEach(template.seatingOptions.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 10) {
                        TEGlyph(kind: .seat, size: 15, color: TEPalette.moss)
                        Text(template.seatingOptions[index])
                            .font(TEType.body(14))
                            .foregroundColor(TEPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    if index < template.seatingOptions.count - 1 { TEQuietRule() }
                }
            }

            TESectionHeader(title: "Exit lines")
            TECard {
                ForEach(template.exitLines.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 10) {
                        TEGlyph(kind: .exit, size: 15, color: TEPalette.clayDeep)
                        Text(template.exitLines[index])
                            .font(TEType.body(14))
                            .foregroundColor(TEPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    if index < template.exitLines.count - 1 { TEQuietRule() }
                }
            }

            if !template.likelyTriggerIDs.isEmpty {
                TESectionHeader(title: "Triggers this situation usually brings")
                TECard {
                    ForEach(template.likelyTriggerIDs, id: \.self) { id in
                        if let trigger = TETriggerCatalog.byID(id) {
                            HStack(spacing: 10) {
                                TEGlyph(kind: .wave, size: 15, color: TEPalette.moss)
                                Text(trigger.name)
                                    .font(TEType.body(14))
                                    .foregroundColor(TEPalette.ink)
                                Spacer(minLength: 0)
                                Text(trigger.triggerClass.shortTitle)
                                    .font(TEType.body(11))
                                    .foregroundColor(TEPalette.inkFaint)
                            }
                        }
                    }
                }
            }

            TESectionHeader(title: "Starting techniques")
            ForEach(template.suggestedTechniqueIDs, id: \.self) { id in
                if let technique = TETechniqueCatalog.byID(id) {
                    TENavRow(title: technique.title,
                             detail: technique.whenToUse,
                             leading: { TERowBadge(glyph: technique.isScript ? .speech : .leaf) },
                             destination: { TETechniqueDetailView(techniqueID: id) })
                }
            }

            NavigationLink(destination: TEPlanEditorView(templateID: templateID, existingPlanID: nil)) {
                HStack(spacing: 10) {
                    TEGlyph(kind: .plus, size: 18, color: TEPalette.card, weight: 2.0)
                    Text("Build a plan from this")
                        .font(TEType.title(15.5))
                        .foregroundColor(TEPalette.card)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(TEPalette.moss)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
    }
}

// MARK: - New plan: pick a starting point

struct TENewPlanView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        TEPage(title: "New plan",
               subtitle: "Start from a situation, or build it yourself.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TENavRow(title: "From scratch",
                     detail: TESituationTemplates.blank.blurb,
                     leading: { TERowBadge(glyph: .edit, tint: TEPalette.clay) },
                     destination: { TEPlanEditorView(templateID: "blank", existingPlanID: nil) })

            TESectionHeader(title: "Situations", note: "\(TESituationTemplates.all.count)")

            ForEach(TESituationTemplates.all) { template in
                TENavRow(title: template.name,
                         detail: template.blurb,
                         leading: { TERowBadge(glyph: .seat) },
                         destination: { TEPlanEditorView(templateID: template.id, existingPlanID: nil) })
            }
        }
    }
}
