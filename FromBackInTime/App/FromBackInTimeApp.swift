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
    @State private var container = DependencyContainer()
    @State private var appState = AppState()
    @State private var mockStore = MockAppStore()

    // MARK: - Global stores (long-lived, shared across screens)

    // @State private var authStore: AuthStore
    // @State private var cardStore: CardStore

    // init() {
    //     let container = DependencyContainer()
    //     _container = State(wrappedValue: container)
    //     _authStore = State(wrappedValue: container.makeAuthStore())
    //     _cardStore = State(wrappedValue: container.makeCardStore())
    // }

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
                .environment(mockStore)
            // .environment(authStore)    // global stores injected here
            // .environment(cardStore)
            .preferredColorScheme(.light)   // app is light-only by design
        }
    }
}
