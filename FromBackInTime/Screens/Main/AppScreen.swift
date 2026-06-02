//
//  AppScreen.swift
//  FromBackInTime
//
//  Base scaffold for every tab. Wraps content in a NavigationStack and gives
//  each tab the same top bar: a Create (+) action on the leading side and a
//  Settings (gear) action on the trailing side. Both open sheets.
//

import SwiftUI

struct AppScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    @State private var showCreate = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(AppBackground())
                .scrollContentBackground(.hidden)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            Haptics.selection()
                            showCreate = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .accessibilityLabel("Create a message")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.selection()
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .accessibilityLabel("Settings")
                    }
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
