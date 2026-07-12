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
                    Text("Start with a small one: a 60-second voice note to someone you love, delivered one year from today.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, AppSpacing.xl)

                Button("Record my first message") { finish(startCreate: true) }
                    .primaryButton()
                Button("Explore the app first") { finish(startCreate: false) }
                    .textButton()
                    .padding(.top, AppSpacing.xs)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }

    private func finish(startCreate: Bool) {
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
        appState.pendingFirstCreate = startCreate
        appState.completeOnboarding()
    }
}
