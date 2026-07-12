//
//  FromBackInTimeApp.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Combine
import SwiftUI

@main
struct FromBackInTimeApp: App {
    @State private var router = Router.base
    @State private var container: DependencyContainer
    @State private var appState = AppState()

    // Global stores (long-lived, shared across screens).
    @State private var authStore: AuthStore
    @State private var appStore: MockAppStore

    // Superwall hard paywall: gates the app after onboarding.
    @State private var paywall = PaywallManager()

    init() {
        let container = DependencyContainer()
        _container = State(wrappedValue: container)
        _authStore = State(wrappedValue: container.makeAuthStore())
        _appStore = State(wrappedValue: container.makeAppStore())
    }

    var body: some Scene {
        WindowGroup {
            RootView()              // onboarding until finished, then the main tab bar
                .sheet(item: $router.sheet) { destination in
                    RouterDestinationView(destination: destination)
                }
                .fullScreenCover(item: $router.fullScreenSheet) { destination in
                    RouterDestinationView(destination: destination)
                }
                .environment(router)
                .environment(container)
                .environment(appState)
                .environment(authStore)
                .environment(appStore)
                .environment(paywall)
                .preferredColorScheme(.light)   // app is light-only by design
                .task {
                    // Configure Superwall first so entitlement status starts
                    // resolving before we decide whether to gate the app.
                    paywall.configure()
                    // Onboarding-first: establish an anonymous session so every
                    // authed call has a token, then load the user's data.
                    await authStore.ensureSession()
                    // Tie the paywall/entitlement to the account.
                    paywall.identify(userId: authStore.state.userId)
                    // A returning, signed-in user (e.g. after a reinstall that
                    // wiped the onboarding flag but kept the Keychain session)
                    // shouldn't be marched back through onboarding.
                    if authStore.state.isAuthenticated, !authStore.state.isAnonymous {
                        appState.completeOnboarding()
                    }
                    await appStore.bootstrap()
                    await authStore.loadProfile()
                }
                .onReceive(NotificationCenter.default.publisher(for: .sessionReplaced)) { _ in
                    // The signed-in identity changed (sign-in, sign-out, or a
                    // dead session healed to anonymous): reload user data so
                    // no screen keeps the previous user's vault.
                    Task {
                        await appStore.load()
                        await authStore.loadProfile()
                    }
                }
        }
    }
}
