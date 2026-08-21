import SwiftUI

/// Post-hoc scoring. Difficulty is asked first, before the technique questions, so the score
/// is not coloured by deciding what worked.
struct TEPlanScoreView: View {
    let planID: UUID

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var run = TEPlanRun()
    @State private var prepared = false
    @State private var rateSeating = false
    @State private var rateMasking = false
    @FocusState private var focused: TEFieldID?

    private var plan: TEPlan? { store.plan(id: planID) }

    var body: some View {
        Group {
            if let plan = plan {
                content(plan)
            } else {
                TEPage(title: "Score", onBack: { presentationMode.wrappedValue.dismiss() }) {
                    TEEmptyState(glyph: .plan, title: "This plan is gone",
                                 message: "It was deleted, so there is nothing to score.")
                }
            }
        }
        .onAppear { prepare() }
    }

    private func content(_ plan: TEPlan) -> some View {
        TEPage(title: "How did it go?",
               subtitle: plan.name,
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TESectionHeader(title: "How hard was it")
            TECard {
                TEScalePicker(value: run.difficulty,
                              lowLabel: "Fine",
                              highLabel: "As bad as it gets") { run.difficulty = $0 }
                Text(difficultyWords)
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            TESectionHeader(title: "Did you need to leave")
            TECard {
                HStack(spacing: 8) {
                    scoreToggle(title: "I stayed", active: !run.neededToLeave) { run.neededToLeave = false }
                    scoreToggle(title: "I left at some point", active: run.neededToLeave) { run.neededToLeave = true }
                }
                TEFootnote(text: "Leaving is a legitimate outcome. It is recorded because it is useful, not because it counts against you.")
            }

            if !plan.seatingOption.isEmpty {
                TESectionHeader(title: "The position you chose")
                TECard {
                    Text(plan.seatingOption)
                        .font(TEType.body(14.5))
                        .foregroundColor(TEPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    TEToggleRow(title: "Rate how much it helped", isOn: rateSeating) { value in
                        rateSeating = value
                        // Test the original value BEFORE clamping, or the -1 sentinel is
                        // already 0 by the time the neutral default is checked for.
                        if value {
                            run.seatingHelped = run.seatingHelped < 0 ? 5 : run.seatingHelped
                        } else {
                            run.seatingHelped = -1
                        }
                    }
                    if rateSeating {
                        TEScalePicker(value: max(0, run.seatingHelped),
                                      lowLabel: "Made no difference",
                                      highLabel: "Made the difference",
                                      tintByValue: false) { run.seatingHelped = $0 }
                    }
                }
            }

            if let preset = TEMaskPreset(rawValue: plan.maskingPreset), preset != .none {
                TESectionHeader(title: "The masking you chose")
                TECard {
                    Text(preset.title)
                        .font(TEType.body(14.5))
                        .foregroundColor(TEPalette.ink)
                    TEToggleRow(title: "Rate how much it helped", isOn: rateMasking) { value in
                        rateMasking = value
                        if value {
                            run.maskingHelped = run.maskingHelped < 0 ? 5 : run.maskingHelped
                        } else {
                            run.maskingHelped = -1
                        }
                    }
                    if rateMasking {
                        TEScalePicker(value: max(0, run.maskingHelped),
                                      lowLabel: "Made no difference",
                                      highLabel: "Made the difference",
                                      tintByValue: false) { run.maskingHelped = $0 }
                    }
                }
            }

            TESectionHeader(title: "The techniques you had ready")
            if run.outcomes.isEmpty {
                TEFootnote(text: "This plan had no techniques attached.")
            } else {
                ForEach(run.outcomes.indices, id: \.self) { index in
                    outcomeCard(index)
                }
            }

            TESectionHeader(title: "Anything worth remembering", note: "optional")
            TETextArea(placeholder: "Sat at the end and it was much better than last time. The extractor fan helped more than I expected.",
                       text: $run.note,
                       minHeight: 96,
                       focus: $focused,
                       field: .runNote)

            TEPrimaryButton(title: "Save this run", glyph: .check) {
                focused = nil
                run.date = Date()
                store.addRun(run, toPlanID: planID)
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 6)

            TEFootnote(text: "Every scored run feeds the strategy ranking. Below three samples the app says \"still learning\" rather than showing a number it cannot stand behind.")
        }
    }

    private func outcomeCard(_ index: Int) -> some View {
        let outcome = run.outcomes[index]
        let technique = TETechniqueCatalog.byID(outcome.techniqueID)
        return TECard {
            HStack(alignment: .top, spacing: 10) {
                TEGlyph(kind: (technique?.isScript ?? false) ? .speech : .leaf, size: 17, color: TEPalette.moss)
                VStack(alignment: .leading, spacing: 2) {
                    Text(technique?.title ?? "Technique")
                        .font(TEType.medium(15))
                        .foregroundColor(TEPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(technique?.whenToUse ?? "")
                        .font(TEType.body(11.5))
                        .foregroundColor(TEPalette.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                scoreToggle(title: "Didn't use it", active: !outcome.used) {
                    run.outcomes[index].used = false
                }
                scoreToggle(title: "Used it", active: outcome.used) {
                    run.outcomes[index].used = true
                }
            }
            if outcome.used {
                TEScalePicker(value: outcome.helped,
                              lowLabel: "Did nothing",
                              highLabel: "Really helped",
                              tintByValue: false) { run.outcomes[index].helped = $0 }
            }
        }
    }

    private func scoreToggle(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(TEType.medium(13.5))
                .foregroundColor(active ? TEPalette.card : TEPalette.inkSoft)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(active ? TEPalette.moss : TEPalette.sand)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(active ? TEPalette.moss : TEPalette.cardEdge, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var difficultyWords: String {
        switch run.difficulty {
        case 0...1: return "Barely registered."
        case 2...3: return "Noticeable, manageable."
        case 4...5: return "Hard work, but you got through it."
        case 6...7: return "Genuinely difficult."
        case 8...9: return "Very hard. That is worth recording plainly."
        default: return "As bad as it gets. Give yourself proper recovery time afterwards."
        }
    }

    private func prepare() {
        guard !prepared, let plan = plan else { return }
        prepared = true
        var fresh = TEPlanRun()
        fresh.outcomes = plan.techniqueIDs.map { TETechniqueOutcome(techniqueID: $0) }
        fresh.seatingHelped = -1
        fresh.maskingHelped = -1
        run = fresh
        rateSeating = false
        rateMasking = false
    }
}
