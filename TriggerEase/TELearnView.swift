import SwiftUI

struct TELearnView: View {
    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var query = ""
    @State private var sectionFilter: String?
    @FocusState private var focused: TEFieldID?

    var body: some View {
        TEPage(title: "Learn",
               subtitle: "\(TELearnCatalog.all.count) short cards. Written to be honest about what is known and what is not.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TECard(background: TEPalette.claySoft.opacity(0.45), border: TEPalette.clay.opacity(0.35)) {
                Text("The short version")
                    .font(TEType.medium(14.5))
                    .foregroundColor(TEPalette.clayDeep)
                Text("Misophonia describes a strong, involuntary reaction to specific everyday sounds. It is not currently listed as a distinct disorder in the major diagnostic manuals — that is a statement about classification, not about whether the experience is real. This app does not diagnose anything and nothing here is medical advice.")
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.clayDeep.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }

            TESearchField(placeholder: "Search the library", text: $query, focus: $focused)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "All", selected: sectionFilter == nil) { sectionFilter = nil }
                    ForEach(TELearnCatalog.sections, id: \.self) { section in
                        TEChip(title: section, selected: sectionFilter == section) {
                            sectionFilter = sectionFilter == section ? nil : section
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            if filtered.isEmpty {
                TEEmptyState(glyph: .search,
                             title: "Nothing matches",
                             message: "Try a shorter word, or clear the section filter.")
            } else {
                ForEach(visibleSections, id: \.self) { section in
                    let items = filtered.filter { $0.section == section }
                    if !items.isEmpty {
                        TESectionHeader(title: section, note: "\(items.count)")
                        ForEach(items, id: \.id) { card in
                            TENavRow(title: card.title,
                                     detail: firstLine(card),
                                     badge: store.isLearnCardRead(card.id) ? "read" : nil,
                                     leading: { TERowBadge(glyph: .book,
                                                           tint: store.isLearnCardRead(card.id) ? TEPalette.moss : TEPalette.clay) },
                                     destination: { TELearnCardView(cardID: card.id) })
                        }
                    }
                }
            }
        }
    }

    private func firstLine(_ card: TELearnCard) -> String {
        guard let first = card.paragraphs.first else { return "" }
        if first.count <= 110 { return first }
        let index = first.index(first.startIndex, offsetBy: 108)
        return String(first[first.startIndex..<index]) + "…"
    }

    private var filtered: [TELearnCard] {
        var items = TELearnCatalog.search(query)
        if let section = sectionFilter { items = items.filter { $0.section == section } }
        return items
    }

    private var visibleSections: [String] {
        TELearnCatalog.sections.filter { section in filtered.contains { $0.section == section } }
    }
}

struct TELearnCardView: View {
    let cardID: String

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode

    private var card: TELearnCard? { TELearnCatalog.byID(cardID) }

    var body: some View {
        Group {
            if let card = card {
                content(card)
            } else {
                TEPage(title: "Learn", onBack: { presentationMode.wrappedValue.dismiss() }) {
                    TEEmptyState(glyph: .book, title: "Not found",
                                 message: "This card is not in the library.")
                }
            }
        }
        .onAppear { store.markLearnCardRead(cardID) }
    }

    private func content(_ card: TELearnCard) -> some View {
        TEPage(title: card.title,
               subtitle: card.section,
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            ForEach(card.paragraphs.indices, id: \.self) { index in
                Text(card.paragraphs[index])
                    .font(TEType.body(15))
                    .foregroundColor(index == 0 ? TEPalette.ink : TEPalette.inkSoft)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 2)
            }

            TEQuietRule()

            TESectionHeader(title: "Next in this section")
            ForEach(neighbours(card), id: \.id) { other in
                TENavRow(title: other.title,
                         detail: other.section,
                         leading: { TERowBadge(glyph: .book, tint: TEPalette.clay) },
                         destination: { TELearnCardView(cardID: other.id) })
            }

            TEDisclaimerCard()
        }
    }

    private func neighbours(_ card: TELearnCard) -> [TELearnCard] {
        TELearnCatalog.inSection(card.section)
            .filter { $0.id != card.id }
            .prefix(3)
            .map { $0 }
    }
}
