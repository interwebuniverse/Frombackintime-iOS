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
    @State private var bootCreate: Bool = UserDefaults.standard.bool(forKey: "bootIntoCreate")

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.hasCompletedOnboarding)
        .sheet(isPresented: $bootCreate) { CreateView() }
    }
}

#Preview {
    RootView()
        .environment(AppState())
        .environment(Router.base)
        .environment(DependencyContainer())
}
