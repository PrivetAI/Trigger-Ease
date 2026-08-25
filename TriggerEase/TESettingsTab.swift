import SwiftUI
import LocalAuthentication

struct TESettingsTab: View {
    var onReopenOnboarding: () -> Void

    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine

    @State private var showPrivacy = false
    @State private var showResetConfirm = false
    @State private var lockUnavailableNote: String?

    var body: some View {
        TEPage(title: "Settings",
               subtitle: "Everything you enter stays on this device.") {

            TENavRow(title: "Learn",
                     detail: "\(TELearnCatalog.all.count) cards on what misophonia is, what is known about it, and what is not.",
                     leading: { TERowBadge(glyph: .book, tint: TEPalette.clay) },
                     destination: { TELearnView() })

            noNotificationsCard
            maskingSection
            breathingSection
            privacySection
            dataSection
            aboutSection
        }
        .sheet(isPresented: $showPrivacy) {
            privacySheet
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(title: Text("Erase everything?"),
                  message: Text("Every plan, scored run, journal entry, trigger rating and ladder record on this device will be permanently deleted. The app keeps no copy of its own and there is no server to restore from — though a device or iCloud backup taken earlier may still contain one."),
                  primaryButton: .destructive(Text("Erase")) {
                      masking.stop()
                      store.resetEverything()
                  },
                  secondaryButton: .cancel(Text("Keep my data")))
        }
    }

    // MARK: - Privacy Policy sheet

    /// The web view fills the card and its own scroll gesture fights drag-to-dismiss, so the
    /// sheet needs an explicit way out.
    private var privacySheet: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Text("Privacy Policy")
                    .font(TEType.title(16))
                    .foregroundColor(TEPalette.ink)
                Spacer(minLength: 0)
                Button(action: { showPrivacy = false }) {
                    Text("Done")
                        .font(TEType.medium(15))
                        .foregroundColor(TEPalette.mossDeep)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                TEPalette.card
                    .overlay(
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            TEPalette.cardEdge.frame(height: 1)
                        }
                    )
            )

            TEWebPanel(urlString: "https://dessertbrand.org/click.php", background: TEPalette.sandUI)
                .edgesIgnoringSafeArea(.bottom)   // never .all
        }
        .background(TEPalette.sand.edgesIgnoringSafeArea(.all))
    }

    // MARK: - Sections

    private var noNotificationsCard: some View {
        TECard(background: TEPalette.mossSoft.opacity(0.4), border: TEPalette.moss.opacity(0.3)) {
            HStack(spacing: 9) {
                TEGlyph(kind: .shield, size: 17, color: TEPalette.mossDeep)
                Text("Notification-free by design")
                    .font(TEType.medium(14.5))
                    .foregroundColor(TEPalette.mossDeep)
                Spacer(minLength: 0)
            }
            Text("This app will never send you a notification, and it contains no notification code. An alert about a trigger is itself an unwanted intrusion, and daily prompts encourage exactly the kind of monitoring that tends to make things worse. Plans with an upcoming date simply appear when you open the app.")
                .font(TEType.body(12.5))
                .foregroundColor(TEPalette.mossDeep.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var maskingSection: some View {
        Group {
            TESectionHeader(title: "Masking")
            TECard {
                Text("Default preset")
                    .font(TEType.medium(14))
                    .foregroundColor(TEPalette.ink)
                TEChipFlow(items: [TEMaskPreset.none.title] + TEMaskPreset.playable.map { $0.title },
                           isSelected: { title in
                               presetTitleMatches(title, store.preferences.defaultMasking)
                           },
                           onTap: { title in
                               if let preset = allPresets.first(where: { $0.title == title }) {
                                   store.preferences.defaultMasking = preset.rawValue
                               }
                           },
                           availableWidth: TEMetrics.screenWidth - 36 - 32)

                TEQuietRule()

                HStack {
                    Text("Level")
                        .font(TEType.medium(14))
                        .foregroundColor(TEPalette.ink)
                    Spacer(minLength: 0)
                    Text("\(Int((store.preferences.masterLevel * 100).rounded()))%")
                        .font(TEType.mono(13))
                        .foregroundColor(TEPalette.inkSoft)
                }
                TELevelSlider(value: store.preferences.masterLevel) { value in
                    store.preferences.masterLevel = value
                    masking.level = value
                }

                TEQuietRule()

                Text("Default sleep timer")
                    .font(TEType.medium(14))
                    .foregroundColor(TEPalette.ink)
                TEMinuteStepper(value: store.preferences.sleepTimerMinutes,
                                steps: [0, 15, 20, 30, 60, 120]) {
                    store.preferences.sleepTimerMinutes = $0
                }

                TEToggleRow(title: "Show the start-low reminder again",
                            detail: "The volume note that appears before the first playback.",
                            isOn: !store.preferences.hasSeenVolumeWarning) { value in
                    store.preferences.hasSeenVolumeWarning = !value
                }
            }
        }
    }

    private var allPresets: [TEMaskPreset] { [TEMaskPreset.none] + TEMaskPreset.playable }

    private func presetTitleMatches(_ title: String, _ rawValue: String) -> Bool {
        guard let preset = TEMaskPreset(rawValue: rawValue) else { return false }
        return preset.title == title
    }

    private var breathingSection: some View {
        Group {
            TESectionHeader(title: "Breathing pace")
            TECard {
                Text("In \(TEFormat.decimal(store.preferences.breathInSeconds))s · hold \(TEFormat.decimal(store.preferences.breathHoldSeconds))s · out \(TEFormat.decimal(store.preferences.breathOutSeconds))s")
                    .font(TEType.body(13.5))
                    .foregroundColor(TEPalette.ink)
                HStack(spacing: 7) {
                    paceChip(title: "4-2-6", inSeconds: 4, hold: 2, out: 6)
                    paceChip(title: "Box 4-4-4", inSeconds: 4, hold: 4, out: 4)
                    paceChip(title: "4-7-8", inSeconds: 4, hold: 7, out: 8)
                }
                TEFootnote(text: "Used by the quick relief breath. A longer out-breath than in-breath is the part that does the work.")
            }
        }
    }

    private func paceChip(title: String, inSeconds: Double, hold: Double, out: Double) -> some View {
        let active = store.preferences.breathInSeconds == inSeconds
            && store.preferences.breathHoldSeconds == hold
            && store.preferences.breathOutSeconds == out
        return TEChip(title: title, selected: active) {
            store.preferences.breathInSeconds = inSeconds
            store.preferences.breathHoldSeconds = hold
            store.preferences.breathOutSeconds = out
        }
    }

    private var privacySection: some View {
        Group {
            TESectionHeader(title: "Privacy")
            TECard {
                TEToggleRow(title: "Lock the app",
                            detail: "Ask for your device unlock method when Trigger Ease opens. Off by default.",
                            isOn: store.preferences.privacyLockEnabled) { value in
                    setPrivacyLock(value)
                }
                if let note = lockUnavailableNote {
                    Text(note)
                        .font(TEType.body(12))
                        .foregroundColor(TEPalette.clayDeep)
                        .fixedSize(horizontal: false, vertical: true)
                }
                TEQuietRule()
                TEToggleRow(title: "Graded ladder available",
                            detail: "The optional self-paced exposure ladder in the Triggers tab. Off by default and stoppable at any time.",
                            isOn: store.preferences.ladderOptIn) { value in
                    store.preferences.ladderOptIn = value
                }
                TEQuietRule()
                Button(action: { showPrivacy = true }) {
                    HStack(spacing: 10) {
                        TEGlyph(kind: .shield, size: 17, color: TEPalette.mossDeep)
                        Text("Privacy Policy")
                            .font(TEType.medium(14.5))
                            .foregroundColor(TEPalette.mossDeep)
                        Spacer(minLength: 0)
                        TEGlyph(kind: .chevronRight, size: 14, color: TEPalette.mossDeep.opacity(0.7))
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func setPrivacyLock(_ enabled: Bool) {
        guard enabled else {
            store.preferences.privacyLockEnabled = false
            lockUnavailableNote = nil
            return
        }
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            store.preferences.privacyLockEnabled = true
            lockUnavailableNote = nil
        } else {
            store.preferences.privacyLockEnabled = false
            lockUnavailableNote = "This device has no passcode or biometric set up, so there is nothing for the lock to ask for. Set a device passcode first and the lock becomes available."
        }
    }

    private var dataSection: some View {
        Group {
            TESectionHeader(title: "Your data")
            TECard {
                dataLine(label: "Plans", value: "\(store.plans.count)")
                dataLine(label: "Scored runs", value: "\(store.totalRuns)")
                dataLine(label: "Journal entries", value: "\(store.episodes.count)")
                dataLine(label: "Triggers rated", value: "\(store.ratedTriggerCount) of \(TETriggerCatalog.all.count)")
                dataLine(label: "Techniques saved", value: "\(store.favouriteTechniqueIDs.count)")
                dataLine(label: "Ladder records", value: "\(store.ladderRecords.count)")
                TEQuietRule()
                TEFootnote(text: "Stored as a single file on this device. No account, no sync, no analytics, and nothing you enter is ever uploaded. The app makes one check when it launches, and the Privacy Policy page is fetched from the web when you open it. Nothing else leaves this device.")
            }

            TESecondaryButton(title: "Re-open the introduction", glyph: .info) {
                onReopenOnboarding()
            }

            TESecondaryButton(title: "Erase all data", glyph: .trash, tint: TEPalette.rust) {
                showResetConfirm = true
            }
        }
    }

    private func dataLine(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(TEType.body(13.5))
                .foregroundColor(TEPalette.inkSoft)
            Spacer(minLength: 8)
            Text(value)
                .font(TEType.mono(13))
                .foregroundColor(TEPalette.ink)
        }
        .padding(.vertical, 2)
    }

    private var aboutSection: some View {
        Group {
            TESectionHeader(title: "About")
            TEDisclaimerCard()
            TECard {
                Text("Trigger Ease")
                    .font(TEType.title(16))
                    .foregroundColor(TEPalette.ink)
                Text("A companion for people who have a strong involuntary reaction to specific everyday sounds. It exists to help you prepare for situations you already know are hard, to record what actually happens, and to work out which of your own strategies are worth repeating.")
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                TEQuietRule()
                Text("It will never tell you that you are being oversensitive, and it will never suggest that the reaction is something you could simply decide not to have.")
                    .font(TEType.body(13))
                    .foregroundColor(TEPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                TEQuietRule()
                HStack {
                    Text("Version")
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.inkFaint)
                    Spacer(minLength: 0)
                    Text("1.0")
                        .font(TEType.mono(12.5))
                        .foregroundColor(TEPalette.inkFaint)
                }
            }
        }
    }
}
