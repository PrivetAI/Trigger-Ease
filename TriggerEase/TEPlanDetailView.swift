import SwiftUI

struct TEPlanDetailView: View {
    let planID: UUID

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDeleteConfirm = false

    private var plan: TEPlan? { store.plan(id: planID) }

    var body: some View {
        Group {
            if let plan = plan {
                content(plan)
            } else {
                TEPage(title: "Plan", onBack: { presentationMode.wrappedValue.dismiss() }) {
                    TEEmptyState(glyph: .plan,
                                 title: "This plan is gone",
                                 message: "It was deleted. Go back to see the rest of your plans.")
                }
            }
        }
        .alert(isPresented: $showDeleteConfirm) {
            Alert(title: Text("Delete this plan?"),
                  message: Text("The plan and all of its scored runs will be removed from this device. This cannot be undone."),
                  primaryButton: .destructive(Text("Delete")) {
                      store.deletePlan(id: planID)
                      presentationMode.wrappedValue.dismiss()
                  },
                  secondaryButton: .cancel(Text("Keep it")))
        }
    }

    private func content(_ plan: TEPlan) -> some View {
        TEPage(title: plan.name,
               subtitle: subtitle(plan),
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            NavigationLink(destination: TEPreflightView(planID: planID)) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(TEPalette.card.opacity(0.22))
                        TEGlyph(kind: .leaf, size: 20, color: TEPalette.card, weight: 1.8)
                    }
                    .frame(width: 38, height: 38)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Open the pre-flight card")
                            .font(TEType.title(16))
                            .foregroundColor(TEPalette.card)
                        Text("Large type, in order, for the moment itself")
                            .font(TEType.body(12))
                            .foregroundColor(TEPalette.card.opacity(0.85))
                    }
                    Spacer(minLength: 0)
                    TEGlyph(kind: .chevronRight, size: 16, color: TEPalette.card.opacity(0.8))
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(TEPalette.mossDeep)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            TESectionHeader(title: "The plan")
            TECard {
                detailLine(glyph: .clock, label: "When", value: TEFormat.dateTime.string(from: plan.scheduledAt))
                TEQuietRule()
                detailLine(glyph: .seat, label: "Position",
                           value: plan.seatingOption.isEmpty ? "Not chosen" : plan.seatingOption)
                TEQuietRule()
                detailLine(glyph: .volume, label: "Masking",
                           value: TEMaskPreset(rawValue: plan.maskingPreset)?.title ?? "No masking")
                TEQuietRule()
                detailLine(glyph: .exit, label: "Exit line",
                           value: plan.exitLine.isEmpty ? "Not written yet" : plan.exitLine)
                if !plan.supportPerson.isEmpty {
                    TEQuietRule()
                    detailLine(glyph: .person, label: "Support", value: plan.supportPerson)
                }
                if !plan.note.isEmpty {
                    TEQuietRule()
                    detailLine(glyph: .edit, label: "Note", value: plan.note)
                }
            }

            if !plan.techniqueIDs.isEmpty {
                TESectionHeader(title: "Techniques ready")
                ForEach(plan.techniqueIDs, id: \.self) { id in
                    if let technique = TETechniqueCatalog.byID(id) {
                        TENavRow(title: technique.title,
                                 detail: technique.whenToUse,
                                 leading: { TERowBadge(glyph: technique.isScript ? .speech : .leaf) },
                                 destination: { TETechniqueDetailView(techniqueID: id) })
                    }
                }
            }

            if !plan.expectedTriggerIDs.isEmpty {
                TESectionHeader(title: "Triggers expected", note: "\(plan.expectedTriggerIDs.count)")
                TECard(padding: 13) {
                    ForEach(plan.expectedTriggerIDs, id: \.self) { id in
                        if let trigger = TETriggerCatalog.byID(id) {
                            HStack(spacing: 9) {
                                TEGlyph(kind: .wave, size: 14, color: TEPalette.moss)
                                Text(trigger.name)
                                    .font(TEType.body(13.5))
                                    .foregroundColor(TEPalette.ink)
                                Spacer(minLength: 0)
                                if let rating = store.rating(for: id) {
                                    TEIntensityPip(value: rating, size: 24)
                                }
                            }
                        }
                    }
                }
            }

            historySection(plan)

            NavigationLink(destination: TEPlanScoreView(planID: planID)) {
                HStack(spacing: 10) {
                    TEGlyph(kind: .edit, size: 18, color: TEPalette.card, weight: 1.9)
                    Text("Score how it went")
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
            .padding(.top, 6)

            NavigationLink(destination: TEPlanEditorView(templateID: plan.templateID.isEmpty ? "blank" : plan.templateID,
                                                         existingPlanID: planID)) {
                HStack(spacing: 8) {
                    TEGlyph(kind: .edit, size: 16, color: TEPalette.mossDeep)
                    Text("Edit this plan")
                        .font(TEType.medium(15))
                        .foregroundColor(TEPalette.mossDeep)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(TEPalette.mossDeep.opacity(0.4), lineWidth: 1.2)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            TESecondaryButton(title: "Delete plan", glyph: .trash, tint: TEPalette.rust) {
                showDeleteConfirm = true
            }
        }
    }

    private func subtitle(_ plan: TEPlan) -> String {
        let template = TESituationTemplates.byID(plan.templateID)?.name ?? "Custom situation"
        return "\(template) · \(TEPlanEngine.trendSentence(for: plan))"
    }

    private func detailLine(glyph: TEGlyphKind, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            TEGlyph(kind: glyph, size: 16, color: TEPalette.moss)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(TEType.medium(11))
                    .foregroundColor(TEPalette.inkFaint)
                Text(value)
                    .font(TEType.body(14))
                    .foregroundColor(TEPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 3)
    }

    private func historySection(_ plan: TEPlan) -> some View {
        Group {
            TESectionHeader(title: "History", note: plan.runs.isEmpty ? "none yet" : "\(plan.runs.count)")
            if plan.runs.isEmpty {
                TEFootnote(text: "Score it after the situation and this becomes a record you can look back on — and it feeds the strategy ranking.")
            } else {
                if plan.runs.count >= 2 {
                    TECard {
                        Text("Difficulty across repeats")
                            .font(TEType.medium(13))
                            .foregroundColor(TEPalette.inkSoft)
                        TELineChart(points: sortedRuns(plan).map { Double($0.difficulty) },
                                    counts: sortedRuns(plan).map { _ in 1 },
                                    maxValue: 10,
                                    height: 110,
                                    tint: TEPalette.clay)
                        Text(TEPlanEngine.trendSentence(for: plan))
                            .font(TEType.body(12))
                            .foregroundColor(TEPalette.inkFaint)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                ForEach(sortedRuns(plan).reversed()) { run in
                    TECard(padding: 13) {
                        HStack(alignment: .top, spacing: 11) {
                            TEIntensityPip(value: run.difficulty, size: 34)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(TEFormat.shortDate.string(from: run.date))
                                    .font(TEType.medium(13.5))
                                    .foregroundColor(TEPalette.ink)
                                Text(runSummary(run))
                                    .font(TEType.body(12))
                                    .foregroundColor(TEPalette.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        if !run.note.isEmpty {
                            Text(run.note)
                                .font(TEType.body(12.5))
                                .foregroundColor(TEPalette.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private func sortedRuns(_ plan: TEPlan) -> [TEPlanRun] {
        plan.runs.sorted { $0.date < $1.date }
    }

    private func runSummary(_ run: TEPlanRun) -> String {
        var parts: [String] = ["difficulty \(run.difficulty)/10"]
        parts.append(run.neededToLeave ? "left at some point" : "stayed")
        let used = run.outcomes.filter { $0.used }
        if used.isEmpty {
            parts.append("no techniques used")
        } else {
            let names = used.compactMap { TETechniqueCatalog.byID($0.techniqueID)?.title }
            parts.append("used \(names.joined(separator: ", "))")
        }
        return parts.joined(separator: " · ")
    }
}
