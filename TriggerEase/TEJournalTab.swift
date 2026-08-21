import SwiftUI

struct TEJournalTab: View {
    @EnvironmentObject private var store: TEStore

    @State private var classFilter: TETriggerClass?
    @State private var roleFilter: TEPersonRole?
    @State private var windowDays: Int = 0
    @State private var minIntensity: Int = 0

    var body: some View {
        TEPage(title: "Journal",
               subtitle: "What happened, how hard it was, and how long it took to come down.") {

            NavigationLink(destination: TEEpisodeEditorView(existingID: nil)) {
                HStack(spacing: 10) {
                    TEGlyph(kind: .plus, size: 19, color: TEPalette.card, weight: 2.0)
                    Text("Log an episode")
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

            if store.episodes.isEmpty {
                TEEmptyState(glyph: .journal,
                             title: "Nothing logged yet",
                             message: "Two lines is enough: what the sound was, how bad it got, and how long it took to settle.\n\nPatterns you cannot see day to day become obvious across thirty entries — and a written record is taken seriously by clinicians and by skeptical family members alike.")
            } else {
                headlineCard
                TENavRow(title: "Analytics",
                         detail: "Worst triggers, worst contexts, time of day, weekly trend and recovery.",
                         leading: { TERowBadge(glyph: .chart, tint: TEPalette.clay) },
                         destination: { TEJournalAnalyticsView() })
                filterSection
                listSection
            }

            TEDisclaimerCard(compact: true)
        }
    }

    // MARK: - Headline

    private var headlineCard: some View {
        let head = TEAnalytics.headline(store.episodes)
        return TECard {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(head.total)")
                        .font(TEType.display(30))
                        .foregroundColor(TEPalette.ink)
                    Text(head.total == 1 ? "entry" : "entries")
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkFaint)
                    Text(weekComparison(head))
                        .font(TEType.body(11.5))
                        .foregroundColor(TEPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                if let mean = head.meanIntensity {
                    TEDial(value: mean, maxValue: 10, caption: "mean\nintensity", size: 78,
                           tint: TEPalette.intensity(Int(mean.rounded())))
                }
            }
            TEQuietRule()
            // "Highest" and "typical" cannot be said from one or two entries. Below the sample
            // floor the card says so rather than printing a figure that reads as representative.
            if head.total < TEAnalytics.minimumSamples {
                TENotEnoughData(needed: TEAnalytics.minimumSamples, have: head.total)
            } else {
                if let worst = head.worstTrigger {
                    HStack(spacing: 9) {
                        TEGlyph(kind: .wave, size: 15, color: TEPalette.rust)
                        Text("Highest mean intensity: \(worst)")
                            .font(TEType.body(13))
                            .foregroundColor(TEPalette.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
                if let recovery = head.meanRecovery, recovery > 0 {
                    HStack(spacing: 9) {
                        TEGlyph(kind: .clock, size: 15, color: TEPalette.clayDeep)
                        Text("Typical recovery: about \(Int(recovery.rounded())) minutes, across \(head.total) entries")
                            .font(TEType.body(13))
                            .foregroundColor(TEPalette.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private func weekComparison(_ head: TEAnalytics.Headline) -> String {
        if head.last7 == 0 && head.previous7 == 0 { return "Nothing in the last two weeks." }
        let difference = head.last7 - head.previous7
        if difference == 0 { return "\(head.last7) in the last 7 days, same as the week before." }
        if difference > 0 { return "\(head.last7) in the last 7 days, \(difference) more than the week before." }
        return "\(head.last7) in the last 7 days, \(-difference) fewer than the week before."
    }

    // MARK: - Filters

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            TESectionHeader(title: "Filter", note: "\(filtered.count) of \(store.episodes.count)")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "All time", selected: windowDays == 0) { windowDays = 0 }
                    TEChip(title: "7 days", selected: windowDays == 7) { windowDays = 7 }
                    TEChip(title: "30 days", selected: windowDays == 30) { windowDays = 30 }
                    TEChip(title: "90 days", selected: windowDays == 90) { windowDays = 90 }
                }
                .padding(.vertical, 2)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "Any class", selected: classFilter == nil) { classFilter = nil }
                    ForEach(TETriggerClass.allCases, id: \.self) { klass in
                        TEChip(title: klass.shortTitle, selected: classFilter == klass) {
                            classFilter = classFilter == klass ? nil : klass
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "Anyone", selected: roleFilter == nil, tint: TEPalette.clay) { roleFilter = nil }
                    ForEach(TEPersonRole.allCases, id: \.self) { role in
                        TEChip(title: role.title, selected: roleFilter == role, tint: TEPalette.clay) {
                            roleFilter = roleFilter == role ? nil : role
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    TEChip(title: "Any intensity", selected: minIntensity == 0, tint: TEPalette.rust) { minIntensity = 0 }
                    TEChip(title: "5 and up", selected: minIntensity == 5, tint: TEPalette.rust) { minIntensity = 5 }
                    TEChip(title: "7 and up", selected: minIntensity == 7, tint: TEPalette.rust) { minIntensity = 7 }
                    TEChip(title: "9 and up", selected: minIntensity == 9, tint: TEPalette.rust) { minIntensity = 9 }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var filtered: [TEEpisode] {
        var items = store.episodesNewestFirst
        if windowDays > 0 {
            let cutoff = Date().addingTimeInterval(-Double(windowDays) * 86400)
            items = items.filter { $0.date >= cutoff }
        }
        if let klass = classFilter {
            items = items.filter { TETriggerCatalog.byID($0.triggerID)?.triggerClass == klass }
        }
        if let role = roleFilter {
            items = items.filter { $0.role == role }
        }
        if minIntensity > 0 {
            items = items.filter { $0.intensity >= minIntensity }
        }
        return items
    }

    // MARK: - List

    private var listSection: some View {
        Group {
            TESectionHeader(title: "Entries", note: "newest first")
            if filtered.isEmpty {
                TEEmptyState(glyph: .filter,
                             title: "Nothing matches these filters",
                             message: "Widen the window or clear a filter to see your other entries.")
            } else {
                ForEach(filtered) { episode in
                    NavigationLink(destination: TEEpisodeEditorView(existingID: episode.id)) {
                        episodeRow(episode)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private func episodeRow(_ episode: TEEpisode) -> some View {
        HStack(alignment: .top, spacing: 12) {
            TEIntensityPip(value: episode.intensity, size: 38)
            VStack(alignment: .leading, spacing: 4) {
                Text(TETriggerCatalog.byID(episode.triggerID)?.name ?? "Unspecified trigger")
                    .font(TEType.medium(15))
                    .foregroundColor(TEPalette.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(rowDetail(episode))
                    .font(TEType.body(12))
                    .foregroundColor(TEPalette.inkSoft)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if !episode.note.isEmpty {
                    Text(episode.note)
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.inkFaint)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 4)
            TEGlyph(kind: .chevronRight, size: 15, color: TEPalette.inkFaint)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(TEPalette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(TEPalette.cardEdge, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    private func rowDetail(_ episode: TEEpisode) -> String {
        var parts: [String] = [TEFormat.dateTime.string(from: episode.date)]
        if episode.role != .unknown { parts.append(episode.role.title) }
        if !episode.place.isEmpty { parts.append(episode.place) }
        parts.append(episode.response.title.lowercased())
        if episode.recoveryMinutes > 0 { parts.append("recovery \(TEFormat.duration(episode.recoveryMinutes))") }
        return parts.joined(separator: " · ")
    }
}
