//
//  FromBackInTimeApp.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

@main
struct FromBackInTimeApp: App {
    @State private var router = Router.base
    @State private var container: DependencyContainer
    @State private var appState = AppState()

    // Global stores (long-lived, shared across screens).
    @State private var authStore: AuthStore
    @State private var appStore: MockAppStore

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
                .preferredColorScheme(.light)   // app is light-only by design
                .task {
                    // Onboarding-first: establish an anonymous session so every
                    // authed call has a token, then load the user's data.
                    await authStore.ensureSession()
                    await appStore.bootstrap()
                }
        }
    }
}
