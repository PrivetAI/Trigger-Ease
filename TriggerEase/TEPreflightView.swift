import SwiftUI

/// The card the user opens in the moment: what to do, in order, in large readable type,
/// with the two chosen techniques one tap away.
struct TEPreflightView: View {
    let planID: UUID

    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine
    @Environment(\.presentationMode) private var presentationMode
    @State private var expanded: String?

    private var plan: TEPlan? { store.plan(id: planID) }

    var body: some View {
        Group {
            if let plan = plan {
                content(plan)
            } else {
                TEPage(title: "Pre-flight", onBack: { presentationMode.wrappedValue.dismiss() }) {
                    TEEmptyState(glyph: .plan, title: "This plan is gone",
                                 message: "It was deleted while this screen was open.")
                }
            }
        }
    }

    private func content(_ plan: TEPlan) -> some View {
        TEPage(title: plan.name,
               subtitle: TEFormat.dateTime.string(from: plan.scheduledAt),
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            step(number: 1, title: "Where you sit",
                 body: plan.seatingOption.isEmpty ? "No position chosen. Take the end seat if you can." : plan.seatingOption,
                 glyph: .seat)

            maskingStep(plan)

            if plan.techniqueIDs.isEmpty {
                step(number: 3, title: "Techniques", body: "None chosen for this plan.", glyph: .toolkit)
            } else {
                VStack(alignment: .leading, spacing: 9) {
                    stepHeader(number: 3, title: "Ready to use", glyph: .toolkit)
                    ForEach(plan.techniqueIDs, id: \.self) { id in
                        if let technique = TETechniqueCatalog.byID(id) {
                            techniqueCard(technique)
                        }
                    }
                }
            }

            exitStep(plan)

            if !plan.supportPerson.isEmpty {
                step(number: 5, title: "Who already knows", body: plan.supportPerson, glyph: .person)
            }

            if !plan.note.isEmpty {
                step(number: plan.supportPerson.isEmpty ? 5 : 6, title: "Your note", body: plan.note, glyph: .edit)
            }

            TECard(padding: 15, background: TEPalette.mossSoft.opacity(0.45), border: TEPalette.moss.opacity(0.35)) {
                Text("If it goes badly, that is information, not a failure.")
                    .font(TEType.title(15))
                    .foregroundColor(TEPalette.mossDeep)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Score it afterwards either way. A run where nothing worked tells the ranking as much as one where everything did.")
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.mossDeep.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            NavigationLink(destination: TEPlanScoreView(planID: planID)) {
                HStack(spacing: 10) {
                    TEGlyph(kind: .check, size: 18, color: TEPalette.card, weight: 2.0)
                    Text("It's over — score it")
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
        }
    }

    // MARK: - Pieces

    private func stepHeader(number: Int, title: String, glyph: TEGlyphKind) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(TEPalette.moss.opacity(0.16))
                Text("\(number)")
                    .font(TEType.mono(14))
                    .foregroundColor(TEPalette.mossDeep)
            }
            .frame(width: 30, height: 30)
            Text(title)
                .font(TEType.medium(13))
                .tracking(0.6)
                .foregroundColor(TEPalette.inkFaint)
            Spacer(minLength: 0)
            TEGlyph(kind: glyph, size: 17, color: TEPalette.inkFaint)
        }
    }

    private func step(number: Int, title: String, body text: String, glyph: TEGlyphKind) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            stepHeader(number: number, title: title, glyph: glyph)
            TECard(padding: 16) {
                Text(text)
                    .font(TEType.title(TEMetrics.isNarrow ? 18 : 20))
                    .foregroundColor(TEPalette.ink)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func maskingStep(_ plan: TEPlan) -> some View {
        let preset = TEMaskPreset(rawValue: plan.maskingPreset) ?? TEMaskPreset.none
        return VStack(alignment: .leading, spacing: 9) {
            stepHeader(number: 2, title: "What is running", glyph: .volume)
            TECard(padding: 16) {
                Text(preset.title)
                    .font(TEType.title(TEMetrics.isNarrow ? 18 : 20))
                    .foregroundColor(TEPalette.ink)
                Text(preset.blurb)
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                if preset != .none {
                    Button(action: {
                        masking.level = store.preferences.masterLevel
                        masking.toggle(preset, sleepMinutes: nil)
                    }) {
                        HStack(spacing: 9) {
                            TEGlyph(kind: masking.isPlaying && masking.activePreset == preset ? .stop : .play,
                                    size: 16, color: TEPalette.card)
                            Text(masking.isPlaying && masking.activePreset == preset ? "Stop" : "Start it now")
                                .font(TEType.medium(14.5))
                                .foregroundColor(TEPalette.card)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 11)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(TEPalette.moss)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 2)
                    if !store.preferences.hasSeenVolumeWarning {
                        TEFootnote(text: "Start low. Set the level while the room is still quiet — levels chosen mid-episode are usually far too loud.")
                    }
                }
            }
        }
    }

    private func techniqueCard(_ technique: TETechnique) -> some View {
        let isOpen = expanded == technique.id
        return Button(action: {
            expanded = isOpen ? nil : technique.id
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 11) {
                    TEGlyph(kind: technique.isScript ? .speech : .leaf, size: 19, color: TEPalette.moss, weight: 1.8)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(technique.title)
                            .font(TEType.title(17))
                            .foregroundColor(TEPalette.ink)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(technique.whenToUse)
                            .font(TEType.body(12.5))
                            .foregroundColor(TEPalette.inkSoft)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                    TEGlyph(kind: isOpen ? .chevronDown : .chevronRight, size: 16, color: TEPalette.inkFaint)
                }
                if isOpen {
                    TEQuietRule()
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(technique.steps.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(index + 1)")
                                    .font(TEType.mono(13))
                                    .foregroundColor(TEPalette.mossDeep)
                                    .frame(width: 18, alignment: .leading)
                                Text(technique.steps[index])
                                    .font(TEType.body(technique.isScript ? 16 : 15))
                                    .foregroundColor(TEPalette.ink)
                                    .lineSpacing(2.5)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(TEPalette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isOpen ? TEPalette.moss.opacity(0.5) : TEPalette.cardEdge, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func exitStep(_ plan: TEPlan) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            stepHeader(number: 4, title: "If you need to leave, say this", glyph: .exit)
            TECard(padding: 18, background: TEPalette.claySoft.opacity(0.6), border: TEPalette.clay.opacity(0.4)) {
                Text(plan.exitLine.isEmpty ? "Back in a minute." : plan.exitLine)
                    .font(TEType.display(TEMetrics.isNarrow ? 21 : 24))
                    .foregroundColor(TEPalette.clayDeep)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Say it as a statement, already standing. No explanation, no apology.")
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.clayDeep.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
