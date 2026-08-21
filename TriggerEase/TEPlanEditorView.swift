import SwiftUI

struct TEPlanEditorView: View {
    let templateID: String
    let existingPlanID: UUID?

    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine
    @Environment(\.presentationMode) private var presentationMode

    @State private var draft = TEPlan()
    @State private var loaded = false
    @State private var customSeating = ""
    @State private var customExit = ""
    @State private var showValidation = false
    @FocusState private var focused: TEFieldID?

    private var template: TESituationTemplate {
        TESituationTemplates.byID(templateID) ?? TESituationTemplates.blank
    }

    private var isEditing: Bool { existingPlanID != nil }

    /// True when this view was opened to edit a plan that has since been deleted elsewhere.
    /// Without this the editor would collect a save that `updatePlan` silently drops.
    private var recordMissing: Bool {
        guard let id = existingPlanID else { return false }
        return store.plan(id: id) == nil
    }

    var body: some View {
        Group {
            if recordMissing {
                TEPage(title: "Plan", onBack: { presentationMode.wrappedValue.dismiss() }) {
                    TEEmptyState(glyph: .plan,
                                 title: "This plan is gone",
                                 message: "It was deleted, so there is nothing left to edit.")
                }
            } else {
                editor
            }
        }
        .onAppear(perform: prepare)
    }

    private var editor: some View {
        TEPage(title: isEditing ? "Edit plan" : "New plan",
               subtitle: template.id == "blank" ? "Built from scratch." : template.name,
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            nameSection
            whenSection
            triggerSection
            seatingSection
            maskingSection
            techniqueSection
            exitSection
            supportSection
            noteSection

            if showValidation && trimmedName.isEmpty {
                HStack(spacing: 8) {
                    TEGlyph(kind: .warning, size: 16, color: TEPalette.rust)
                    Text("Give the plan a name so you can find it again.")
                        .font(TEType.body(13))
                        .foregroundColor(TEPalette.rust)
                }
            }

            TEPrimaryButton(title: isEditing ? "Save changes" : "Save plan",
                            glyph: .check,
                            action: save)
                .padding(.top, 6)

            if isEditing {
                TESecondaryButton(title: "Done without saving", tint: TEPalette.inkSoft) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Name it")
            TETextField(placeholder: "Sunday lunch at Mom's",
                        text: $draft.name,
                        focus: $focused,
                        field: .planName)
            TEFootnote(text: "Reuse the same plan every time this situation comes round, and it builds a history.")
        }
    }

    private var whenSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            TESectionHeader(title: "When")
            TEDateTimeChooser(date: $draft.scheduledAt)
        }
    }

    private var triggerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Triggers you expect", note: "\(draft.expectedTriggerIDs.count)")
            if draft.expectedTriggerIDs.isEmpty {
                TEFootnote(text: "Optional, but naming them makes the ranking useful later.")
            } else {
                TECard(padding: 13) {
                    ForEach(draft.expectedTriggerIDs, id: \.self) { id in
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
            NavigationLink(destination: TETriggerPickerView(selected: $draft.expectedTriggerIDs,
                                                            suggested: template.likelyTriggerIDs)) {
                pickerButtonLabel(draft.expectedTriggerIDs.isEmpty ? "Choose triggers" : "Change triggers",
                                  glyph: .triggers)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var seatingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Seating and position")
            VStack(spacing: 7) {
                ForEach(seatingOptions, id: \.self) { option in
                    TESelectRow(title: option,
                                selected: draft.seatingOption == option,
                                glyph: .seat) {
                        draft.seatingOption = draft.seatingOption == option ? "" : option
                    }
                }
            }
            TETextField(placeholder: "Or describe your own",
                        text: $customSeating,
                        focus: $focused,
                        field: .planSeating)
            if !customSeating.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                TESecondaryButton(title: "Use this position", glyph: .check) {
                    draft.seatingOption = customSeating.trimmingCharacters(in: .whitespacesAndNewlines)
                    focused = nil
                }
            }
        }
    }

    private var seatingOptions: [String] {
        var options = template.seatingOptions
        let chosen = draft.seatingOption.trimmingCharacters(in: .whitespacesAndNewlines)
        if !chosen.isEmpty && !options.contains(chosen) { options.append(chosen) }
        return options
    }

    private var maskingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Masking")
            TEFootnote(text: "Six presets, one level. Set it before the situation starts — adding it partway through works much less well.")
            VStack(spacing: 7) {
                TESelectRow(title: TEMaskPreset.none.title,
                            selected: draft.maskingPreset == TEMaskPreset.none.rawValue,
                            glyph: .close) {
                    draft.maskingPreset = TEMaskPreset.none.rawValue
                }
                ForEach(TEMaskPreset.playable) { preset in
                    TESelectRow(title: preset.title,
                                detail: preset.blurb,
                                selected: draft.maskingPreset == preset.rawValue,
                                glyph: .volume) {
                        draft.maskingPreset = preset.rawValue
                    }
                }
            }
        }
    }

    private var techniqueSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Two techniques ready", note: "\(draft.techniqueIDs.count) of 2")
            if draft.techniqueIDs.isEmpty {
                TEFootnote(text: "Pick two cards to have one tap away in the moment.")
            } else {
                VStack(spacing: 7) {
                    ForEach(draft.techniqueIDs, id: \.self) { id in
                        if let technique = TETechniqueCatalog.byID(id) {
                            TECard(padding: 12) {
                                HStack(alignment: .top, spacing: 10) {
                                    TEGlyph(kind: technique.isScript ? .speech : .leaf, size: 16, color: TEPalette.moss)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(technique.title)
                                            .font(TEType.medium(14))
                                            .foregroundColor(TEPalette.ink)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(technique.whenToUse)
                                            .font(TEType.body(11.5))
                                            .foregroundColor(TEPalette.inkSoft)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                    }
                }
            }
            NavigationLink(destination: TETechniquePickerView(selected: $draft.techniqueIDs,
                                                              limit: 2,
                                                              suggested: template.suggestedTechniqueIDs)) {
                pickerButtonLabel(draft.techniqueIDs.isEmpty ? "Choose techniques" : "Change techniques",
                                  glyph: .toolkit)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var exitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Your exit line")
            TEFootnote(text: "The exact sentence you will say. Flat and short works better than an explanation.")
            VStack(spacing: 7) {
                ForEach(exitOptions, id: \.self) { line in
                    TESelectRow(title: line,
                                selected: draft.exitLine == line,
                                glyph: .exit) {
                        draft.exitLine = draft.exitLine == line ? "" : line
                    }
                }
            }
            TETextField(placeholder: "Or write your own line",
                        text: $customExit,
                        focus: $focused,
                        field: .planExit)
            if !customExit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                TESecondaryButton(title: "Use this line", glyph: .check) {
                    draft.exitLine = customExit.trimmingCharacters(in: .whitespacesAndNewlines)
                    focused = nil
                }
            }
        }
    }

    private var exitOptions: [String] {
        var options = template.exitLines
        let chosen = draft.exitLine.trimmingCharacters(in: .whitespacesAndNewlines)
        if !chosen.isEmpty && !options.contains(chosen) { options.append(chosen) }
        return options
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Support person", note: "optional")
            TEFootnote(text: "One person who already knows removes most of the social cost of stepping out. A role is enough — you do not have to write a name.")
            TETextField(placeholder: "My sister / the colleague who knows",
                        text: $draft.supportPerson,
                        focus: $focused,
                        field: .planSupport)
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Anything else", note: "optional")
            TETextArea(placeholder: "Leaving at nine. Eat beforehand. Earplugs in the coat pocket.",
                       text: $draft.note,
                       minHeight: 84,
                       focus: $focused,
                       field: .planNote)
        }
    }

    private func pickerButtonLabel(_ title: String, glyph: TEGlyphKind) -> some View {
        HStack(spacing: 8) {
            TEGlyph(kind: glyph, size: 16, color: TEPalette.mossDeep)
            Text(title)
                .font(TEType.medium(14.5))
                .foregroundColor(TEPalette.mossDeep)
            Spacer(minLength: 0)
            TEGlyph(kind: .chevronRight, size: 14, color: TEPalette.mossDeep.opacity(0.7))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(TEPalette.mossDeep.opacity(0.4), lineWidth: 1.2)
        )
        .contentShape(Rectangle())
    }

    // MARK: - Behaviour

    private var trimmedName: String {
        draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func prepare() {
        guard !loaded else { return }
        loaded = true
        if let id = existingPlanID {
            // No fall-through to a fresh draft: a new UUID here would make `save()` a no-op.
            if let existing = store.plan(id: id) { draft = existing }
            return
        }
        var fresh = TEPlan()
        fresh.templateID = template.id
        fresh.name = template.id == "blank" ? "" : template.name
        fresh.scheduledAt = defaultDate()
        fresh.expectedTriggerIDs = defaultTriggers()
        fresh.seatingOption = template.seatingOptions.first ?? ""
        fresh.maskingPreset = template.suggestedMasking
        fresh.techniqueIDs = TEPlanEngine.suggestedTechniques(for: template, plans: store.plans)
        fresh.exitLine = template.exitLines.first ?? ""
        draft = fresh
    }

    private func defaultDate() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        let tomorrow = cal.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return cal.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow) ?? tomorrow
    }

    /// Prefer the triggers this user has actually rated highly, then fall back to the template list.
    private func defaultTriggers() -> [String] {
        let rated = store.topRatedTriggers
            .filter { $0.rating >= 6 && template.likelyTriggerIDs.contains($0.trigger.id) }
            .map { $0.trigger.id }
        if !rated.isEmpty { return Array(rated.prefix(5)) }
        return Array(template.likelyTriggerIDs.prefix(4))
    }

    private func save() {
        guard !trimmedName.isEmpty else {
            showValidation = true
            focused = .planName
            return
        }
        draft.name = trimmedName
        if existingPlanID != nil {
            store.updatePlan(draft)
        } else {
            store.addPlan(draft)
        }
        focused = nil
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Selectable row

struct TESelectRow: View {
    let title: String
    var detail: String? = nil
    let selected: Bool
    var glyph: TEGlyphKind = .check
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(selected ? TEPalette.moss : TEPalette.sandDeep.opacity(0.6))
                        .frame(width: 24, height: 24)
                    if selected {
                        TEGlyph(kind: .check, size: 15, color: TEPalette.card, weight: 2.2)
                    } else {
                        TEGlyph(kind: glyph, size: 13, color: TEPalette.inkFaint, weight: 1.5)
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(TEType.body(14))
                        .foregroundColor(TEPalette.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let detail = detail {
                        Text(detail)
                            .font(TEType.body(11.5))
                            .foregroundColor(TEPalette.inkSoft)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? TEPalette.mossSoft.opacity(0.45) : TEPalette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? TEPalette.moss : TEPalette.cardEdge, lineWidth: selected ? 1.4 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Date and time

/// A custom date and time chooser. No system pickers anywhere in the app.
struct TEDateTimeChooser: View {
    @Binding var date: Date

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(0..<21, id: \.self) { offset in
                        let day = calendar.date(byAdding: .day, value: offset, to: teStartOfDay(Date())) ?? Date()
                        dayChip(day: day, offset: offset)
                    }
                }
                .padding(.vertical, 2)
            }

            TECard(padding: 13) {
                HStack(spacing: 12) {
                    timeStepButton(minutes: -30, glyph: .chevronLeft)
                    VStack(spacing: 2) {
                        Text(TEFormat.clock.string(from: date))
                            .font(TEType.display(26))
                            .foregroundColor(TEPalette.ink)
                        Text(TEFormat.fullDate.string(from: date))
                            .font(TEType.body(11.5))
                            .foregroundColor(TEPalette.inkFaint)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    timeStepButton(minutes: 30, glyph: .chevronRight)
                }
                HStack(spacing: 6) {
                    ForEach([8, 12, 18, 20], id: \.self) { hour in
                        Button(action: { setHour(hour) }) {
                            Text(String(format: "%02d:00", hour))
                                .font(TEType.medium(12))
                                .foregroundColor(currentHour == hour && currentMinute == 0 ? TEPalette.card : TEPalette.inkSoft)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .fill(currentHour == hour && currentMinute == 0 ? TEPalette.moss : TEPalette.sand)
                                )
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    private var currentHour: Int { calendar.component(.hour, from: date) }
    private var currentMinute: Int { calendar.component(.minute, from: date) }

    private func dayChip(day: Date, offset: Int) -> some View {
        let selected = teDayKey(day) == teDayKey(date)
        let label: String
        if offset == 0 { label = "Today" }
        else if offset == 1 { label = "Tomorrow" }
        else { label = TEFormat.weekday.string(from: day) }
        return Button(action: { setDay(day) }) {
            VStack(spacing: 2) {
                Text(label)
                    .font(TEType.medium(11))
                    .foregroundColor(selected ? TEPalette.card : TEPalette.inkSoft)
                Text(TEFormat.dayMonth.string(from: day))
                    .font(TEType.medium(12.5))
                    .foregroundColor(selected ? TEPalette.card : TEPalette.ink)
            }
            .frame(width: 74)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selected ? TEPalette.moss : TEPalette.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selected ? TEPalette.moss : TEPalette.cardEdge, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func timeStepButton(minutes: Int, glyph: TEGlyphKind) -> some View {
        Button(action: { step(minutes) }) {
            ZStack {
                Circle()
                    .fill(TEPalette.sand)
                    .frame(width: 40, height: 40)
                TEGlyph(kind: glyph, size: 18, color: TEPalette.mossDeep, weight: 2.0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func step(_ minutes: Int) {
        guard let updated = calendar.date(byAdding: .minute, value: minutes, to: date) else { return }
        date = updated
    }

    private func setDay(_ day: Date) {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let updated = calendar.date(bySettingHour: components.hour ?? 12,
                                          minute: components.minute ?? 0,
                                          second: 0,
                                          of: day) else { return }
        date = updated
    }

    private func setHour(_ hour: Int) {
        guard let updated = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) else { return }
        date = updated
    }
}
