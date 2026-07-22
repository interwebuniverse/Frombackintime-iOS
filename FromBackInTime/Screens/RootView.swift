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
    @State private var showFirstFinish = false

    var body: some View {
        Group {
            if appStore.bootstrapPhase != .ready || (appState.hasCompletedOnboarding && !paywall.hasAccess) {
                // THE launch surface, and the only one. Every cold start opens
                // here and stays here through loading, load errors (retry +
                // support), and the paywall gate: the hard paywall presents
                // over this same view. It leaves the screen only for
                // onboarding or the unlocked app.
                LaunchView()
                    .transition(.opacity)
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.35), value: paywall.hasAccess)
        .animation(.easeInOut(duration: 0.35), value: appStore.bootstrapPhase)
        .onChange(of: appState.hasCompletedOnboarding) { _, done in
            guard done else { return }
            // A first message recorded during onboarding is waiting: save it
            // now that the paywall unlocked. Wait out the swap animation so
            // the sheet presents cleanly.
            if appState.pendingFirstMessage != nil {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.6))
                    showFirstFinish = true
                }
            } else if appState.pendingFirstCreate {
                appState.pendingFirstCreate = false
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.6))
                    showFirstCreate = true
                }
            }
        }
        .sheet(isPresented: $showFirstCreate) {
            CreateView()
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showFirstFinish) {
            FirstMessageFinishView()
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
