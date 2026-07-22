//
//  AppScreen.swift
//  FromBackInTime
//
//  Base scaffold for every tab, built on AppNavScrollView: a large title that
//  shrinks into the compact glass bar on scroll, circular glass create (+) and
//  settings buttons, an optional search field under the title, and the sky
//  behind everything. The system nav bar stays hidden; pushed detail screens
//  bring their own AppNavScrollView with a back button.
//

import SwiftUI

struct AppScreen<Content: View>: View {
    let title: String
    var searchText: Binding<String>? = nil
    var searchPrompt: String = ""
    var onRefresh: (() async -> Void)? = nil
    @ViewBuilder var content: Content

    @State private var showCreate = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            AppNavScrollView(
                title: title,
                leading: AppNavAction(icon: "app-ic-plus", label: "Create a message") { showCreate = true },
                trailing: AppNavAction(icon: "app-ic-gear", label: "Settings") { showSettings = true },
                searchText: searchText,
                searchPrompt: searchPrompt,
                onRefresh: onRefresh
            ) {
                content
            }
            .tint(AppShellTheme.accent)
            .sheet(isPresented: $showCreate) {
                CreateView()
                    .presentationCornerRadius(28)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationCornerRadius(28)
            }
        }
    }
}
