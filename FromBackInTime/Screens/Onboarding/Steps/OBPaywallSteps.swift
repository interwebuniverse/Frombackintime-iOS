//
//  OBPaywallSteps.swift
//  FromBackInTime
//
//  Act 9. The close: a warm "you're all set" screen that ends onboarding.
//

import SwiftUI

// MARK: - First action (ends onboarding)

struct OBFirstActionView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(OnboardingState.self) private var state
    @Environment(AuthStore.self) private var authStore
    @Environment(PaywallManager.self) private var paywall

    @State private var showFirstRecorder = false

    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-allset")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.5), Self.skyBottom.opacity(0.96)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: AppSpacing.md) {
                    Text("You're all set, \(state.displayName).")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Start with a small one: a short video to someone you love, delivered one year from today.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, AppSpacing.xl)

                Button("Record my first message") {
                    Haptics.feedback(style: .medium)
                    showFirstRecorder = true
                }
                    .primaryButton()
                    .a11y("ob.first.record")
                Button("Explore the app first") { gateAndFinish(payload: nil) }
                    .textButton()
                    .a11y("ob.first.later")
                    .padding(.top, AppSpacing.xs)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
        .fullScreenCover(isPresented: $showFirstRecorder) {
            OBFirstMessageView { payload in
                gateAndFinish(payload: payload)
            }
        }
    }

    /// Sealing the first message and skipping both land here: the Superwall
    /// gated register goes up, and onboarding only finishes inside its access
    /// closure, i.e. once the user is actually through the paywall. The
    /// recorded payload waits in AppState and is saved right after the swap.
    private func gateAndFinish(payload: AppState.FirstMessagePayload?) {
        appState.pendingFirstMessage = payload
        paywall.requireAccess {
            finish()
        }
    }

    private func finish() {
        // Persist what onboarding learned to the backend profile. Works for
        // anonymous sessions too (the app row exists); failures are non-fatal.
        let name = state.name.trimmingCharacters(in: .whitespaces)
        let prefs = Dictionary(
            uniqueKeysWithValues: OnboardingContent.preferenceOptions.map {
                ($0.id, state.preferences.contains($0.id))
            }
        )
        Task {
            await authStore.updateProfile(name: name.isEmpty ? nil : name, notifPrefs: prefs)
        }

        router.fullScreenSheet = nil
        router.popToRoot()
        showFirstRecorder = false
        appState.completeOnboarding()
    }
}
