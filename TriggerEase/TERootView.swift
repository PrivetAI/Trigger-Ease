import SwiftUI
import LocalAuthentication

enum TERootSheet: Identifiable {
    case onboarding
    case quickRelief

    var id: Int {
        switch self {
        case .onboarding: return 1
        case .quickRelief: return 2
        }
    }
}

struct TERootView: View {
    @EnvironmentObject private var store: TEStore
    @EnvironmentObject private var masking: TEMaskingEngine

    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedTab = 0
    @State private var sheet: TERootSheet?
    @State private var unlocked = false
    @State private var lockMessage: String?
    /// Covers the screen while the app is not frontmost, so the app-switcher snapshot does not
    /// show the journal. Only used when the privacy lock is on.
    @State private var obscured = false
    /// Set when the app goes to the background, so returning re-prompts exactly once.
    @State private var relockOnReturn = false

    var body: some View {
        ZStack {
            TEPalette.sand.edgesIgnoringSafeArea(.all)

            if store.preferences.privacyLockEnabled && !unlocked {
                TELockScreen(message: lockMessage, onUnlock: attemptUnlock)
            } else {
                mainInterface
            }

            if obscured && store.preferences.privacyLockEnabled {
                TEPrivacyCover()
            }
        }
        .onAppear(perform: handleAppear)
        .onChange(of: scenePhase) { phase in handleScenePhase(phase) }
        // iOS 15 honours only the LAST .sheet modifier on a view, so this screen has exactly one.
        .sheet(item: $sheet) { which in
            switch which {
            case .onboarding:
                TEOnboardingView(onFinish: {
                    store.preferences.hasSeenOnboarding = true
                    sheet = nil
                })
            case .quickRelief:
                TEQuickReliefView(onClose: { sheet = nil })
                    .environmentObject(store)
                    .environmentObject(masking)
            }
        }
    }

    private var mainInterface: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case 0:
                    NavigationView { TEPlanTab() }
                        .navigationViewStyle(StackNavigationViewStyle())
                case 1:
                    NavigationView { TEJournalTab() }
                        .navigationViewStyle(StackNavigationViewStyle())
                case 2:
                    NavigationView { TETriggersTab() }
                        .navigationViewStyle(StackNavigationViewStyle())
                case 3:
                    NavigationView { TEToolkitTab() }
                        .navigationViewStyle(StackNavigationViewStyle())
                default:
                    NavigationView { TESettingsTab(onReopenOnboarding: { sheet = .onboarding }) }
                        .navigationViewStyle(StackNavigationViewStyle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(index: 0, label: "Plan", glyph: .plan)
            tabButton(index: 1, label: "Journal", glyph: .journal)
            tabButton(index: 2, label: "Triggers", glyph: .triggers)
            tabButton(index: 3, label: "Toolkit", glyph: .toolkit)
            tabButton(index: 4, label: "Settings", glyph: .settings)
            quickReliefButton
        }
        .padding(.top, 7)
        .padding(.bottom, 3)
        .frame(height: TEMetrics.tabBarHeight)
        .background(
            TEPalette.card
                .overlay(
                    VStack(spacing: 0) {
                        TEPalette.cardEdge.frame(height: 1)
                        Spacer(minLength: 0)
                    }
                )
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(index: Int, label: String, glyph: TEGlyphKind) -> some View {
        let active = selectedTab == index
        return Button(action: { selectedTab = index }) {
            VStack(spacing: 3) {
                TEGlyph(kind: glyph, size: 21,
                        color: active ? TEPalette.mossDeep : TEPalette.inkFaint,
                        weight: active ? 2.0 : 1.6)
                Text(label)
                    .font(TEType.medium(9.5))
                    .foregroundColor(active ? TEPalette.mossDeep : TEPalette.inkFaint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Quick relief lives in the tab row rather than floating over content, so it can never
    /// cover the bottom rows of a scroll view.
    private var quickReliefButton: some View {
        Button(action: { sheet = .quickRelief }) {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(TEPalette.moss)
                        .frame(width: 27, height: 27)
                    TEGlyph(kind: .ease, size: 17, color: TEPalette.card, weight: 1.5)
                }
                Text("Ease")
                    .font(TEType.medium(9.5))
                    .foregroundColor(TEPalette.mossDeep)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Lifecycle

    private func handleAppear() {
        let locked = store.preferences.privacyLockEnabled && !unlocked
        if !store.preferences.hasSeenOnboarding && sheet == nil && !locked {
            // Delay a beat so the sheet does not fight the first layout pass.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                if !store.preferences.hasSeenOnboarding { sheet = .onboarding }
            }
        }
        if store.preferences.privacyLockEnabled && !unlocked {
            attemptUnlock()
        }
    }

    /// `.onAppear` fires once per process, so the lock has to be re-armed here or backgrounding
    /// and returning would leave the journal open to anyone who picks the phone up.
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            obscured = true
            // Deliberately NOT `.inactive`: that fires on the way back in as well, and re-locking
            // there would cancel the unlock the user just completed.
            if store.preferences.privacyLockEnabled {
                unlocked = false
                lockMessage = nil
                relockOnReturn = true
            }
        case .inactive:
            obscured = true
        case .active:
            obscured = false
            if relockOnReturn {
                relockOnReturn = false
                if store.preferences.privacyLockEnabled && !unlocked { attemptUnlock() }
            }
        @unknown default:
            break
        }
    }

    private func attemptUnlock() {
        let context = LAContext()
        context.localizedFallbackTitle = ""
        var error: NSError?
        // Device authentication includes the passcode fallback, so a device without biometrics
        // still works. A device with no passcode at all cannot evaluate it — in that case the
        // lock is skipped rather than shutting the user out of their own records.
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            unlocked = true
            lockMessage = nil
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: "Unlock Trigger Ease") { success, _ in
            DispatchQueue.main.async {
                if success {
                    unlocked = true
                    lockMessage = nil
                } else {
                    lockMessage = "Not unlocked. Try again, or turn the lock off in Settings on your next unlocked session."
                }
            }
        }
    }
}

/// Opaque cover drawn while the app is not frontmost, so nothing readable ends up in the
/// app-switcher snapshot.
struct TEPrivacyCover: View {
    var body: some View {
        ZStack {
            TEPalette.sand.edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                TEGlyph(kind: .lock, size: 40, color: TEPalette.moss, weight: 1.8)
                Text("Trigger Ease")
                    .font(TEType.display(19))
                    .foregroundColor(TEPalette.inkSoft)
            }
        }
    }
}

struct TELockScreen: View {
    let message: String?
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            TEPalette.sand.edgesIgnoringSafeArea(.all)
            VStack(spacing: 18) {
                TEGlyph(kind: .lock, size: 46, color: TEPalette.moss, weight: 1.8)
                Text("Trigger Ease is locked")
                    .font(TEType.display(21))
                    .foregroundColor(TEPalette.ink)
                Text("Your journal and plans stay on this device. Unlock with the same method you use to unlock your phone.")
                    .font(TEType.body(13.5))
                    .foregroundColor(TEPalette.inkSoft)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 30)
                if let message = message {
                    Text(message)
                        .font(TEType.body(12.5))
                        .foregroundColor(TEPalette.clayDeep)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 30)
                }
                TEPrimaryButton(title: "Unlock", glyph: .lock, action: onUnlock)
                    .padding(.horizontal, 44)
                    .padding(.top, 6)
            }
        }
    }
}
