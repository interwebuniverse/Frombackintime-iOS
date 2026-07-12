//
//  RootView.swift
//  FromBackInTime
//
//  Top of the view tree. Shows onboarding until it's finished, then swaps
//  to the main tab bar. The swap is animated so the handoff feels intentional.
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthStore.self) private var authStore
    @Environment(MockAppStore.self) private var appStore
    @Environment(PaywallManager.self) private var paywall
    @State private var showFirstCreate = false

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if paywall.isResolving {
                // Brief, cold-launch only: entitlement status still resolving.
                // Show the sky rather than flashing the paywall over a paid user.
                ZStack {
                    AppBackground()
                    ProgressView().tint(AppShellTheme.accent)
                }
                .transition(.opacity)
            } else if paywall.isSubscribed {
                MainTabView()
                    .transition(.opacity)
            } else {
                // Hard gate: finished onboarding but not paying.
                PaywallGateView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.35), value: paywall.isSubscribed)
        .animation(.easeInOut(duration: 0.35), value: paywall.isResolving)
        .onChange(of: appState.hasCompletedOnboarding) { _, done in
            // "Record my first message" chose to jump straight into creating;
            // wait out the swap animation so the sheet presents cleanly.
            guard done, appState.pendingFirstCreate else { return }
            appState.pendingFirstCreate = false
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.6))
                showFirstCreate = true
            }
        }
        .sheet(isPresented: $showFirstCreate) {
            CreateView()
                .presentationCornerRadius(28)
        }
        // A signed-in session that dropped fell back to anonymous: prompt the
        // user to sign back in rather than leaving them staring at an empty vault.
        .sheet(isPresented: Binding(
            get: { authStore.state.sessionExpired },
            set: { if !$0 { authStore.state.sessionExpired = false } }
        )) {
            SignInSheet(
                subtitle: "Your session ended. Sign back in to reach your vault.",
                onSignedIn: {
                    Task {
                        await appStore.load()
                        await authStore.loadProfile()
                    }
                }
            )
        }
    }
}

#Preview {
    let container = DependencyContainer()
    return RootView()
        .environment(AppState())
        .environment(Router.base)
        .environment(container)
        .environment(container.makeAuthStore())
        .environment(container.makeAppStore())
        .environment(PaywallManager())
}
