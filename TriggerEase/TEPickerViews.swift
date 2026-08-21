import SwiftUI

// MARK: - Trigger picker

struct TETriggerPickerView: View {
    @Binding var selected: [String]
    var suggested: [String] = []

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var query = ""
    @State private var classFilter: TETriggerClass?
    @FocusState private var focused: TEFieldID?

    var body: some View {
        TEPage(title: "Triggers",
               subtitle: "\(selected.count) selected of \(TETriggerCatalog.all.count) in the catalogue.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TESearchField(placeholder: "Search the catalogue", text: $query, focus: $focused)

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

            if query.isEmpty && classFilter == nil {
                if !myTopTriggers.isEmpty {
                    TESectionHeader(title: "Rated highest by you")
                    VStack(spacing: 7) {
                        ForEach(myTopTriggers, id: \.id) { trigger in
                            row(trigger)
                        }
                    }
                }
                if !suggestedTriggers.isEmpty {
                    TESectionHeader(title: "Usual for this situation")
                    VStack(spacing: 7) {
                        ForEach(suggestedTriggers, id: \.id) { trigger in
                            row(trigger)
                        }
                    }
                }
            }

            if filtered.isEmpty {
                TEEmptyState(glyph: .search,
                             title: "Nothing matches",
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

            TEPrimaryButton(title: "Done", glyph: .check) {
                focused = nil
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 8)
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

    private var myTopTriggers: [TETrigger] {
        store.topRatedTriggers.filter { $0.rating >= 6 }.prefix(6).map { $0.trigger }
    }

    private var suggestedTriggers: [TETrigger] {
        suggested.compactMap { TETriggerCatalog.byID($0) }
    }

    private func row(_ trigger: TETrigger) -> some View {
        TESelectRow(title: trigger.name,
                    detail: trigger.detail,
                    selected: selected.contains(trigger.id),
                    glyph: .wave) {
            if let index = selected.firstIndex(of: trigger.id) {
                selected.remove(at: index)
            } else {
                selected.append(trigger.id)
            }
        }
    }
}

// MARK: - Technique picker

struct TETechniquePickerView: View {
    @Binding var selected: [String]
    var limit: Int = 2
    var suggested: [String] = []

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var query = ""
    @State private var groupFilter: TETechniqueGroup?
    @FocusState private var focused: TEFieldID?

    var body: some View {
        TEPage(title: "Techniques",
               subtitle: limit > 0
                ? "Pick up to \(limit). \(selected.count) chosen."
                : "\(selected.count) chosen.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TESearchField(placeholder: "Search the deck", text: $query, focus: $focused)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "All", selected: groupFilter == nil) { groupFilter = nil }
                    ForEach(TETechniqueGroup.allCases, id: \.self) { group in
                        TEChip(title: group.title, selected: groupFilter == group) {
                            groupFilter = groupFilter == group ? nil : group
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            if query.isEmpty && groupFilter == nil && !suggestedCards.isEmpty {
                TESectionHeader(title: "Suggested for this situation")
                VStack(spacing: 7) {
                    ForEach(suggestedCards, id: \.id) { technique in
                        row(technique)
                    }
                }
            }

            if !ownBest.isEmpty && query.isEmpty && groupFilter == nil {
                TESectionHeader(title: "Scored best by you", note: "from your own runs")
                VStack(spacing: 7) {
                    ForEach(ownBest, id: \.key) { ranked in
                        if let technique = TETechniqueCatalog.byID(ranked.key) {
                            row(technique, note: "helped \(ranked.displayScore) · \(ranked.samples) uses")
                        }
                    }
                }
            }

            if filtered.isEmpty {
                TEEmptyState(glyph: .search,
                             title: "Nothing matches",
                             message: "Try a shorter word, or clear the group filter.")
            } else {
                ForEach(groups, id: \.self) { group in
                    let items = filtered.filter { $0.group == group }
                    if !items.isEmpty {
                        TESectionHeader(title: group.title, note: "\(items.count)")
                        VStack(spacing: 7) {
                            ForEach(items, id: \.id) { technique in
                                row(technique)
                            }
                        }
                    }
                }
            }

            TEPrimaryButton(title: "Done", glyph: .check) {
                focused = nil
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 8)
        }
    }

    private var filtered: [TETechnique] {
        var items = TETechniqueCatalog.search(query)
        if let group = groupFilter { items = items.filter { $0.group == group } }
        return items
    }

    private var groups: [TETechniqueGroup] {
        TETechniqueGroup.allCases.filter { group in filtered.contains { $0.group == group } }
    }

    private var suggestedCards: [TETechnique] {
        suggested.compactMap { TETechniqueCatalog.byID($0) }
    }

    private var ownBest: [TEPlanEngine.Ranked] {
        Array(TEPlanEngine.techniqueRanking(plans: store.plans).filter { $0.confident }.prefix(4))
    }

    private func row(_ technique: TETechnique, note: String? = nil) -> some View {
        let isSelected = selected.contains(technique.id)
        let atLimit = limit > 0 && selected.count >= limit && !isSelected
        return TESelectRow(title: technique.title,
                           detail: note ?? technique.whenToUse,
                           selected: isSelected,
                           glyph: technique.isScript ? .speech : .leaf) {
            if let index = selected.firstIndex(of: technique.id) {
                selected.remove(at: index)
            } else if !atLimit {
                selected.append(technique.id)
            } else if limit > 0 {
                // Replace the oldest choice rather than silently doing nothing.
                selected.removeFirst()
                selected.append(technique.id)
            }
        }
        .opacity(atLimit ? 0.72 : 1)
    }
}
