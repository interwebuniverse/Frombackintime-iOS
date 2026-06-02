//
//  MainTabView.swift
//  FromBackInTime
//
//  The main app shell after onboarding. Three tabs: Home, People, Library.
//  Create (+) and Settings (gear) live in each tab's top bar, not the tab bar.
//

import SwiftUI

struct MainTabView: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: Binding(
            get: { router.selectedTab },
            set: { new in
                if new != router.selectedTab { Haptics.selection() }
                router.selectedTab = new
            }
        )) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            PeopleView()
                .tabItem { Label("People", systemImage: "person.2.fill") }
                .tag(1)

            LibraryView()
                .tabItem { Label("Library", systemImage: "play.square.stack.fill") }
                .tag(2)
        }
        .tint(AppShellTheme.accent)
    }
}

#Preview {
    MainTabView()
        .environment(Router.base)
        .environment(AppState())
}
