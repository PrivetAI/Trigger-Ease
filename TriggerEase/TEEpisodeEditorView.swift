import SwiftUI

struct TEEpisodeEditorView: View {
    let existingID: UUID?

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var draft = TEEpisode()
    @State private var prepared = false
    @State private var showDeleteConfirm = false
    @State private var showTriggerWarning = false
    @FocusState private var focused: TEFieldID?

    private var isEditing: Bool { existingID != nil }

    /// True when this view was opened to edit an entry that has since been deleted elsewhere.
    /// Without this the editor would happily collect a save that `updateEpisode` silently drops.
    private var recordMissing: Bool {
        guard let id = existingID else { return false }
        return !store.episodes.contains { $0.id == id }
    }

    var body: some View {
        Group {
            if recordMissing {
                TEPage(title: "Entry", onBack: { presentationMode.wrappedValue.dismiss() }) {
                    TEEmptyState(glyph: .journal,
                                 title: "This entry is gone",
                                 message: "It was deleted, so there is nothing left to edit.")
                }
            } else {
                editor
            }
        }
        .onAppear(perform: prepare)
        .alert(isPresented: $showDeleteConfirm) {
            Alert(title: Text("Delete this entry?"),
                  message: Text("It will be removed from this device and from the analytics. This cannot be undone."),
                  primaryButton: .destructive(Text("Delete")) {
                      if let id = existingID { store.deleteEpisode(id: id) }
                      presentationMode.wrappedValue.dismiss()
                  },
                  secondaryButton: .cancel(Text("Keep it")))
        }
    }

    private var editor: some View {
        TEPage(title: isEditing ? "Edit entry" : "Log an episode",
               subtitle: isEditing ? TEFormat.dateTime.string(from: draft.date) : "It takes about thirty seconds.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            triggerSection
            whenSection
            intensitySection
            whoSection
            placeSection
            physicalSection
            responseSection
            timingSection
            noteSection

            if showTriggerWarning && draft.triggerID.isEmpty {
                HStack(spacing: 8) {
                    TEGlyph(kind: .warning, size: 16, color: TEPalette.rust)
                    Text("Choose which trigger it was so the entry can count toward the analytics.")
                        .font(TEType.body(13))
                        .foregroundColor(TEPalette.rust)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            TEPrimaryButton(title: isEditing ? "Save changes" : "Save entry", glyph: .check, action: save)
                .padding(.top, 6)

            if isEditing {
                TESecondaryButton(title: "Delete this entry", glyph: .trash, tint: TEPalette.rust) {
                    showDeleteConfirm = true
                }
            }
        }
    }

    // MARK: - Sections

    private var triggerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "What was it")
            if let trigger = TETriggerCatalog.byID(draft.triggerID) {
                TECard(padding: 13) {
                    HStack(alignment: .top, spacing: 10) {
                        TEGlyph(kind: .wave, size: 17, color: TEPalette.moss)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(trigger.name)
                                .font(TEType.medium(15))
                                .foregroundColor(TEPalette.ink)
                            Text(trigger.triggerClass.title)
                                .font(TEType.body(11.5))
                                .foregroundColor(TEPalette.inkFaint)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            NavigationLink(destination: TESingleTriggerPickerView(selected: $draft.triggerID)) {
                HStack(spacing: 8) {
                    TEGlyph(kind: .triggers, size: 16, color: TEPalette.mossDeep)
                    Text(draft.triggerID.isEmpty ? "Choose the trigger" : "Change trigger")
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
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var whenSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "When")
            HStack(spacing: 7) {
                quickTimeButton(title: "Just now", minutes: 0)
                quickTimeButton(title: "1 h ago", minutes: 60)
                quickTimeButton(title: "3 h ago", minutes: 180)
                quickTimeButton(title: "Yesterday", minutes: 60 * 24)
            }
            TECard(padding: 12) {
                HStack(spacing: 10) {
                    Button(action: { shift(-30) }) {
                        ZStack {
                            Circle().fill(TEPalette.sand).frame(width: 38, height: 38)
                            TEGlyph(kind: .chevronLeft, size: 17, color: TEPalette.mossDeep, weight: 2.0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    VStack(spacing: 1) {
                        Text(TEFormat.clock.string(from: draft.date))
                            .font(TEType.display(22))
                            .foregroundColor(TEPalette.ink)
                        Text(TEFormat.shortDate.string(from: draft.date))
                            .font(TEType.body(11.5))
                            .foregroundColor(TEPalette.inkFaint)
                    }
                    .frame(maxWidth: .infinity)
                    Button(action: { shift(30) }) {
                        ZStack {
                            Circle().fill(TEPalette.sand).frame(width: 38, height: 38)
                            TEGlyph(kind: .chevronRight, size: 17, color: TEPalette.mossDeep, weight: 2.0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private func quickTimeButton(title: String, minutes: Int) -> some View {
        Button(action: {
            draft.date = Date().addingTimeInterval(-Double(minutes) * 60)
        }) {
            Text(title)
                .font(TEType.medium(12.5))
                .foregroundColor(TEPalette.inkSoft)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(TEPalette.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(TEPalette.cardEdge, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func shift(_ minutes: Int) {
        draft.date = draft.date.addingTimeInterval(Double(minutes) * 60)
    }

    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "How intense")
            TECard {
                TEScalePicker(value: draft.intensity,
                              lowLabel: "Noticed it",
                              highLabel: "Overwhelming") { draft.intensity = $0 }
            }
        }
    }

    private var whoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Who was involved", note: "a role, not a name")
            TEChipFlow(items: TEPersonRole.allCases.map { $0.title },
                       isSelected: { $0 == draft.role.title },
                       onTap: { title in
                           if let role = TEPersonRole.allCases.first(where: { $0.title == title }) {
                               draft.role = role
                           }
                       },
                       tint: TEPalette.clay)
            TEFootnote(text: "Roles keep the journal usable if somebody else ever reads it, and they group far better than names in the analytics.")
        }
    }

    private var placeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Where", note: "optional")
            TETextField(placeholder: "Kitchen / office / train",
                        text: $draft.place,
                        focus: $focused,
                        field: .episodePlace)
            if !recentPlaces.isEmpty {
                TEChipFlow(items: recentPlaces,
                           isSelected: { $0.lowercased() == draft.place.lowercased() },
                           onTap: { draft.place = $0 })
            }
        }
    }

    private var recentPlaces: [String] {
        var seen: [String] = []
        for episode in store.episodesNewestFirst {
            let place = episode.place.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !place.isEmpty else { continue }
            if !seen.contains(where: { $0.lowercased() == place.lowercased() }) {
                seen.append(place)
            }
            if seen.count >= 6 { break }
        }
        return seen
    }

    private var physicalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "What your body did", note: "\(draft.physical.count) selected")
            TEChipFlow(items: TEPhysicalSign.allCases.map { $0.title },
                       isSelected: { title in
                           guard let sign = TEPhysicalSign.allCases.first(where: { $0.title == title }) else { return false }
                           return draft.physical.contains(sign)
                       },
                       onTap: { title in
                           guard let sign = TEPhysicalSign.allCases.first(where: { $0.title == title }) else { return }
                           if let index = draft.physical.firstIndex(of: sign) {
                               draft.physical.remove(at: index)
                           } else {
                               draft.physical.append(sign)
                           }
                       })
        }
    }

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "What you did")
            VStack(spacing: 7) {
                ForEach(TEResponse.allCases, id: \.self) { response in
                    TESelectRow(title: response.title,
                                selected: draft.response == response,
                                glyph: glyph(for: response)) {
                        draft.response = response
                    }
                }
            }
        }
    }

    private func glyph(for response: TEResponse) -> TEGlyphKind {
        switch response {
        case .endured: return .shield
        case .masked: return .volume
        case .left: return .exit
        case .asked: return .speech
        case .distracted: return .leaf
        case .movedSeat: return .seat
        case .other: return .edit
        }
    }

    private var timingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            TESectionHeader(title: "How long")
            VStack(alignment: .leading, spacing: 6) {
                Text("It went on for")
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                TEMinuteStepper(value: draft.durationMinutes,
                                steps: [1, 5, 15, 30, 60, 120]) { draft.durationMinutes = $0 }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("It took this long to come down")
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                TEMinuteStepper(value: draft.recoveryMinutes,
                                steps: [0, 5, 15, 30, 60, 120]) { draft.recoveryMinutes = $0 }
            }
            TEFootnote(text: "Recovery usually outlasts the sound. Recording it separately is what lets the app tell you your own typical figure.")
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TESectionHeader(title: "Note", note: "optional")
            TETextArea(placeholder: "Slept badly. Sat opposite this time, which was a mistake.",
                       text: $draft.note,
                       minHeight: 90,
                       focus: $focused,
                       field: .episodeNote)
        }
    }

    // MARK: - Behaviour

    private func prepare() {
        guard !prepared else { return }
        prepared = true
        if let id = existingID {
            // No fall-through to a fresh draft: a new UUID here would make `save()` a no-op.
            if let existing = store.episodes.first(where: { $0.id == id }) { draft = existing }
            return
        }
        var fresh = TEEpisode()
        fresh.date = Date()
        if let top = store.topRatedTriggers.first, top.rating >= 6 {
            fresh.triggerID = top.trigger.id
        }
        draft = fresh
    }

    private func save() {
        guard !draft.triggerID.isEmpty else {
            showTriggerWarning = true
            return
        }
        draft.place = draft.place.trimmingCharacters(in: .whitespacesAndNewlines)
        focused = nil
        if isEditing {
            store.updateEpisode(draft)
        } else {
            store.addEpisode(draft)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Single trigger picker

struct TESingleTriggerPickerView: View {
    @Binding var selected: String

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var query = ""
    @State private var classFilter: TETriggerClass?
    @FocusState private var focused: TEFieldID?

    var body: some View {
        TEPage(title: "Which trigger",
               subtitle: "\(TETriggerCatalog.all.count) in the catalogue, across six classes.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TESearchField(placeholder: "Search", text: $query, focus: $focused)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "All", selected: classFilter == nil) { classFilter = nil }
                    ForEach(TETriggerClass.allCases, id: \.self) { klass in
                        TEChip(title: klass.shortTitle, selected: classFilter == klass) {
                            classFilter = classFilter == klass ? nil : klass
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            if query.isEmpty && classFilter == nil && !frequent.isEmpty {
                TESectionHeader(title: "You log these most")
                VStack(spacing: 7) {
                    ForEach(frequent, id: \.id) { trigger in
                        row(trigger)
                    }
                }
            }

            if filtered.isEmpty {
                TEEmptyState(glyph: .search, title: "Nothing matches",
                             message: "Try a shorter word, or clear the class filter.")
            } else {
                ForEach(groupedClasses, id: \.self) { klass in
                    let items = filtered.filter { $0.triggerClass == klass }
                    if !items.isEmpty {
                        TESectionHeader(title: klass.title, note: "\(items.count)")
                        VStack(spacing: 7) {
                            ForEach(items, id: \.id) { trigger in
                                row(trigger)
                            }
                        }
                    }
                }
            }
        }
    }

    private var filtered: [TETrigger] {
        var items = TETriggerCatalog.search(query)
        if let klass = classFilter { items = items.filter { $0.triggerClass == klass } }
        return items
    }

    private var groupedClasses: [TETriggerClass] {
        TETriggerClass.allCases.filter { klass in filtered.contains { $0.triggerClass == klass } }
    }

    private var frequent: [TETrigger] {
        var counts: [String: Int] = [:]
        for episode in store.episodes where !episode.triggerID.isEmpty {
            counts[episode.triggerID, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
            .prefix(5)
            .compactMap { TETriggerCatalog.byID($0.key) }
    }

    private func row(_ trigger: TETrigger) -> some View {
        TESelectRow(title: trigger.name,
                    detail: trigger.detail,
                    selected: selected == trigger.id,
                    glyph: .wave) {
            selected = trigger.id
            focused = nil
            presentationMode.wrappedValue.dismiss()
        }
    }
}
