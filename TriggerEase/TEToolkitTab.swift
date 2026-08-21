import SwiftUI

struct TEToolkitTab: View {
    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine

    @State private var query = ""
    @State private var groupFilter: TETechniqueGroup?
    @State private var favouritesOnly = false
    @FocusState private var focused: TEFieldID?

    var body: some View {
        TEPage(title: "Toolkit",
               subtitle: "\(TETechniqueCatalog.all.count) cards, including \(TETechniqueCatalog.scripts.count) things to say out loud.") {

            TENavRow(title: "Masking sounds",
                     detail: masking.isPlaying
                        ? "\(masking.activePreset.title) is playing."
                        : "Six presets, one level, one sleep timer.",
                     badge: masking.isPlaying ? "on" : nil,
                     leading: { TERowBadge(glyph: .volume, tint: TEPalette.mossDeep) },
                     destination: { TEMaskingView() })

            TENavRow(title: "Communication scripts",
                     detail: "\(TETechniqueCatalog.scripts.count) conversations, written out so they can be read on screen while you talk.",
                     leading: { TERowBadge(glyph: .speech, tint: TEPalette.clay) },
                     destination: { TEScriptsView() })

            TESearchField(placeholder: "Search the deck", text: $query, focus: $focused)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "All", selected: groupFilter == nil && !favouritesOnly) {
                        groupFilter = nil
                        favouritesOnly = false
                    }
                    TEChip(title: "Favorites", selected: favouritesOnly, tint: TEPalette.clay) {
                        favouritesOnly.toggle()
                    }
                    ForEach(TETechniqueGroup.allCases, id: \.self) { group in
                        TEChip(title: group.title, selected: groupFilter == group) {
                            groupFilter = groupFilter == group ? nil : group
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            if favouritesOnly && store.favouriteTechniqueIDs.isEmpty {
                TEEmptyState(glyph: .star,
                             title: "No favorites yet",
                             message: "Open a card and mark it. Favorites come first when you are building a plan and when you are in a hurry.")
            } else if filtered.isEmpty {
                TEEmptyState(glyph: .search,
                             title: "Nothing matches",
                             message: "Try a shorter word, or clear the filters.")
            } else {
                ForEach(groups, id: \.self) { group in
                    let items = filtered.filter { $0.group == group }
                    if !items.isEmpty {
                        TESectionHeader(title: group.title, note: "\(items.count)")
                        ForEach(items, id: \.id) { technique in
                            TENavRow(title: technique.title,
                                     detail: technique.whenToUse,
                                     badge: store.isFavourite(technique.id) ? "saved" : nil,
                                     leading: { TERowBadge(glyph: technique.isScript ? .speech : .leaf,
                                                           tint: technique.isScript ? TEPalette.clay : TEPalette.moss) },
                                     destination: { TETechniqueDetailView(techniqueID: technique.id) })
                        }
                    }
                }
            }
        }
    }

    private var filtered: [TETechnique] {
        var items = TETechniqueCatalog.search(query)
        if let group = groupFilter { items = items.filter { $0.group == group } }
        if favouritesOnly { items = items.filter { store.isFavourite($0.id) } }
        return items
    }

    private var groups: [TETechniqueGroup] {
        TETechniqueGroup.allCases.filter { group in filtered.contains { $0.group == group } }
    }
}

// MARK: - Technique detail

struct TETechniqueDetailView: View {
    let techniqueID: String

    @EnvironmentObject private var store: TEStore
    @Environment(\.presentationMode) private var presentationMode

    private var technique: TETechnique? { TETechniqueCatalog.byID(techniqueID) }

    var body: some View {
        Group {
            if let technique = technique {
                content(technique)
            } else {
                TEPage(title: "Technique", onBack: { presentationMode.wrappedValue.dismiss() }) {
                    TEEmptyState(glyph: .toolkit, title: "Not found",
                                 message: "This card is not in the deck.")
                }
            }
        }
    }

    private func content(_ technique: TETechnique) -> some View {
        TEPage(title: technique.title,
               subtitle: technique.group.title,
               onBack: { presentationMode.wrappedValue.dismiss() },
               trailing: AnyView(favouriteButton)) {

            TECard(background: TEPalette.mossSoft.opacity(0.4), border: TEPalette.moss.opacity(0.3)) {
                Text("When to use it")
                    .font(TEType.medium(12))
                    .tracking(0.6)
                    .foregroundColor(TEPalette.mossDeep)
                Text(technique.whenToUse)
                    .font(TEType.body(14.5))
                    .foregroundColor(TEPalette.mossDeep)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            TESectionHeader(title: technique.isScript ? "What to say" : "Steps",
                            note: "\(technique.steps.count)")

            ForEach(technique.steps.indices, id: \.self) { index in
                TECard(padding: 15) {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle().fill(TEPalette.moss.opacity(0.14))
                            Text("\(index + 1)")
                                .font(TEType.mono(13))
                                .foregroundColor(TEPalette.mossDeep)
                        }
                        .frame(width: 28, height: 28)
                        Text(technique.steps[index])
                            .font(TEType.body(technique.isScript ? 17 : 15))
                            .foregroundColor(TEPalette.ink)
                            .lineSpacing(technique.isScript ? 4 : 3)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }

            if technique.isScript {
                TEFootnote(text: "Hold the phone where you can see it. Reading a line off a screen mid-conversation is far easier than remembering it, and nobody minds.")
            }

            usageSection

            TESectionHeader(title: "Related")
            ForEach(related, id: \.id) { other in
                TENavRow(title: other.title,
                         detail: other.whenToUse,
                         leading: { TERowBadge(glyph: other.isScript ? .speech : .leaf,
                                               tint: other.isScript ? TEPalette.clay : TEPalette.moss) },
                         destination: { TETechniqueDetailView(techniqueID: other.id) })
            }
        }
    }

    private var favouriteButton: some View {
        Button(action: { store.toggleFavourite(techniqueID) }) {
            HStack(spacing: 6) {
                TEGlyph(kind: store.isFavourite(techniqueID) ? .starFilled : .star,
                        size: 17,
                        color: store.isFavourite(techniqueID) ? TEPalette.clay : TEPalette.inkFaint)
                Text(store.isFavourite(techniqueID) ? "Saved" : "Save")
                    .font(TEType.medium(13.5))
                    .foregroundColor(store.isFavourite(techniqueID) ? TEPalette.clayDeep : TEPalette.inkFaint)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .stroke(store.isFavourite(techniqueID) ? TEPalette.clay.opacity(0.5) : TEPalette.cardEdge,
                            lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var usageSection: some View {
        Group {
            let ranked = TEPlanEngine.techniqueRanking(plans: store.plans).first { $0.key == techniqueID }
            if let item = ranked {
                TESectionHeader(title: "How it has gone for you")
                TECard {
                    TEBarRow(label: "Mean helped",
                             value: item.confident ? item.meanHelped : 0,
                             maxValue: 10,
                             caption: item.confident
                                ? "\(item.samples) uses across your scored runs"
                                : "still learning · \(item.samples) of \(TEPlanEngine.minimumSamples) uses",
                             tint: item.confident ? TEPalette.moss : TEPalette.sandDeep,
                             valueText: item.confident ? nil : "—")
                }
            }
        }
    }

    private var related: [TETechnique] {
        guard let technique = technique else { return [] }
        return TETechniqueCatalog.inGroup(technique.group)
            .filter { $0.id != technique.id }
            .prefix(3)
            .map { $0 }
    }
}

// MARK: - Scripts

struct TEScriptsView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        TEPage(title: "What to say",
               subtitle: "Written to get a need met, not to win an argument. Nobody in these scripts is the villain.",
               onBack: { presentationMode.wrappedValue.dismiss() }) {

            TECard(background: TEPalette.claySoft.opacity(0.45), border: TEPalette.clay.opacity(0.35)) {
                Text("Two things that make these land")
                    .font(TEType.medium(14.5))
                    .foregroundColor(TEPalette.clayDeep)
                Text("Ask at a neutral time, not mid-episode. And ask for one specific, small change rather than for understanding — understanding is optional, the seating arrangement is not.")
                    .font(TEType.body(12.5))
                    .foregroundColor(TEPalette.clayDeep.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(TETechniqueCatalog.scripts, id: \.id) { script in
                TENavRow(title: script.title,
                         detail: script.whenToUse,
                         leading: { TERowBadge(glyph: .speech, tint: TEPalette.clay) },
                         destination: { TETechniqueDetailView(techniqueID: script.id) })
            }
        }
    }
}
