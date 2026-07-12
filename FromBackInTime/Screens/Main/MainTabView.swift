//
//  MainTabView.swift
//  FromBackInTime
//
//  The main app shell after onboarding. Three tabs: Home, People, Library.
//  Create (+) and Settings (gear) live in each tab's top bar, not the tab bar.
//  The tab bar is a translucent material with clean icons8 glyphs, tinted to
//  the accent when active.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @Environment(Router.self) private var router

    init() { Self.styleTabBar() }

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
                .tabItem { Label { Text("Home") } icon: { Image("app-tab-home") } }
                .tag(0)

            PeopleView()
                .tabItem { Label { Text("People") } icon: { Image("app-tab-people") } }
                .tag(1)

            LibraryView()
                .tabItem { Label { Text("Library") } icon: { Image("app-tab-library") } }
                .tag(2)
        }
        .tint(AppShellTheme.accent)
        .onAppear {
#if DEBUG
            // Debug: launch with `-startTab N` to open a specific tab for review.
            let t = UserDefaults.standard.integer(forKey: "startTab")
            if t > 0, t < 3 { router.selectedTab = t }
#endif
        }
    }

    /// Clean, translucent bar: system material background, hairline top, gray
    /// inactive items, accent active. Set once so it applies app-wide.
    private static func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.06)

        let items: [UITabBarItemAppearance] = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance,
        ]
        let inactive = UIColor(AppShellTheme.subtitle)
        let active = UIColor(AppShellTheme.accent)
        for item in items {
            item.normal.iconColor = inactive
            item.normal.titleTextAttributes = [.foregroundColor: inactive]
            item.selected.iconColor = active
            item.selected.titleTextAttributes = [.foregroundColor: active]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environment(Router.base)
        .environment(AppState())
}
