//
//  AppScreen.swift
//  FromBackInTime
//
//  Base scaffold for every tab. A custom header (plain icons8 create + settings
//  actions and a big rounded title) sits directly on the sky, so there's no
//  iOS 26 toolbar "glass" capsule behind the buttons. The system nav bar is
//  hidden here; pushed detail screens bring their own back button.
//

import SwiftUI

struct AppScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    @State private var showCreate = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                header
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppBackground())
            .toolbar(.hidden, for: .navigationBar)
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

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                headerButton("app-ic-plus", label: "Create a message") { showCreate = true }
                Spacer()
                headerButton("app-ic-gear", label: "Settings") { showSettings = true }
            }
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, OnboardingSafe.screenPadding)
        .padding(.top, AppSpacing.xs)
        .padding(.bottom, AppSpacing.md)
    }

    /// Bare icons8 glyph, accent-tinted, on the sky — no backing capsule.
    private func headerButton(_ name: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            AppIcon(name: name, size: 25, color: AppShellTheme.accent)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// Small shim so the header's horizontal inset matches the rest of the app
/// without reaching across theme namespaces at every call site.
private enum OnboardingSafe {
    static let screenPadding: CGFloat = AppShellTheme.screenPadding
}
