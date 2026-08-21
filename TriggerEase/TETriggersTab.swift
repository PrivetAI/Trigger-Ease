import SwiftUI

struct TETriggersTab: View {
    @EnvironmentObject private var store: TEStore

    @State private var query = ""
    @State private var classFilter: TETriggerClass?
    @State private var showRatedOnly = true
    @State private var gridTriggerID: String?
    @FocusState private var focused: TEFieldID?

    var body: some View {
        TEPage(title: "Triggers",
               subtitle: "Rate what hits you and how hard. Unrated sounds stay neutral — there is no obligation to fill this in.") {

            // Hidden push target for taps on the heat grid.
            NavigationLink(destination: gridDestination, isActive: gridBinding) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .opacity(0)

            profileCard
            heatGridSection

            TESearchField(placeholder: "Search \(TETriggerCatalog.all.count) triggers", text: $query, focus: $focused)

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

            if filtered.isEmpty {
                TEEmptyState(glyph: .search,
                             title: "Nothing matches",
                             message: "Try a shorter word, or clear the class filter.")
            } else {
                ForEach(visibleClasses, id: \.self) { klass in
                    let items = filtered.filter { $0.triggerClass == klass }
                    if !items.isEmpty {
                        TESectionHeader(title: klass.title, note: "\(items.count)")
                        Text(klass.blurb)
                            .font(TEType.body(12.5))
                            .foregroundColor(TEPalette.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(items, id: \.id) { trigger in
                            triggerRow(trigger)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Profile

    private var profileCard: some View {
        TECard {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(store.ratedTriggerCount)")
                        .font(TEType.display(30))
                        .foregroundColor(TEPalette.ink)
                    Text("rated of \(TETriggerCatalog.all.count)")
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkFaint)
                }
                Spacer(minLength: 0)
                if let mean = teMean(store.triggerRatings.values.map { Double($0) }) {
                    TEDial(value: mean, maxValue: 10, caption: "mean\nrating", size: 74,
                           tint: TEPalette.intensity(Int(mean.rounded())))
                }
            }
            if store.ratedTriggerCount == 0 {
                Text("Rate a handful of the ones you already know about. Six or seven is enough to make the plan builder and the grid useful.")
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                let top = Array(store.topRatedTriggers.prefix(3))
                Text("Highest: " + top.map { "\($0.trigger.name) (\($0.rating))" }.joined(separator: ", "))
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Heat grid

    private var heatGridSection: some View {
        Group {
            TESectionHeader(title: "Your trigger grid", note: showRatedOnly ? "rated only" : "everything")
            TECard {
                Text("This is the picture you can show somebody who does not believe you. It shows what is not a trigger as clearly as what is.")
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 7) {
                    TEChip(title: "Rated only", selected: showRatedOnly) { showRatedOnly = true }
                    TEChip(title: "Everything", selected: !showRatedOnly) { showRatedOnly = false }
                    Spacer(minLength: 0)
                }

                if gridClasses.isEmpty {
                    TEFootnote(text: "Nothing rated yet. Rate a trigger below and it appears here.")
                } else {
                    ForEach(gridClasses, id: \.self) { klass in
                        let cells = gridCells(for: klass)
                        if !cells.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(klass.shortTitle)
                                    .font(TEType.medium(11.5))
                                    .tracking(0.7)
                                    .foregroundColor(TEPalette.inkFaint)
                                TEHeatGrid(cells: cells,
                                           columns: TEMetrics.isNarrow ? 5 : 6,
                                           availableWidth: gridWidth,
                                           cellHeight: 38,
                                           onTap: { cell in gridTriggerID = cell.key })
                            }
                            .padding(.top, 2)
                        }
                    }
                    TEHeatLegend()
                    TEFootnote(text: "Tap any square to open that trigger. Gray squares are unrated, not zero.")
                }
            }
        }
    }

    /// Page padding (18 each side) plus card padding (16 each side) — every inset subtracted.
    private var gridWidth: CGFloat {
        max(120, TEMetrics.screenWidth - 36 - 32)
    }

    private var gridClasses: [TETriggerClass] {
        TETriggerClass.allCases.filter { !gridCells(for: $0).isEmpty }
    }

    private func gridCells(for klass: TETriggerClass) -> [TEHeatCell] {
        TETriggerCatalog.inClass(klass).compactMap { trigger in
            let rating = store.rating(for: trigger.id)
            if showRatedOnly && rating == nil { return nil }
            return TEHeatCell(key: trigger.id, label: trigger.name, value: rating)
        }
    }

    private var gridBinding: Binding<Bool> {
        Binding(get: { gridTriggerID != nil },
                set: { if !$0 { gridTriggerID = nil } })
    }

    @ViewBuilder private var gridDestination: some View {
        if let id = gridTriggerID {
            TETriggerDetailView(triggerID: id, onBack: { gridTriggerID = nil })
        } else {
            EmptyView()
        }
    }

    // MARK: - List

    private var filtered: [TETrigger] {
        var items = TETriggerCatalog.search(query)
        if let klass = classFilter { items = items.filter { $0.triggerClass == klass } }
        return items
    }

    private var visibleClasses: [TETriggerClass] {
        TETriggerClass.allCases.filter { klass in filtered.contains { $0.triggerClass == klass } }
    }

    private func triggerRow(_ trigger: TETrigger) -> some View {
        let rating = store.rating(for: trigger.id)
        return TECard(padding: 13) {
            NavigationLink(destination: TETriggerDetailView(triggerID: trigger.id, onBack: nil)) {
                HStack(alignment: .top, spacing: 11) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(trigger.name)
                            .font(TEType.medium(15))
                            .foregroundColor(TEPalette.ink)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(trigger.detail)
                            .font(TEType.body(12))
                            .foregroundColor(TEPalette.inkSoft)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    TEGlyph(kind: .chevronRight, size: 15, color: TEPalette.inkFaint)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            TEQuietRule()

            TEScalePicker(value: rating ?? 0,
                          lowLabel: rating == nil ? "Not rated" : "Fine",
                          highLabel: "Unbearable") { value in
                store.setRating(value, for: trigger.id)
            }

            if rating != nil {
                Button(action: { store.setRating(nil, for: trigger.id) }) {
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
    }
}
