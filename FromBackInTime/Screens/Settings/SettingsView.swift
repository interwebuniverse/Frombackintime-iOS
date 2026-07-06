//
//  SettingsView.swift
//  FromBackInTime
//
//  Reached from the gear in the top-right of every tab. Account, plan,
//  notifications, legal, and sign out.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore
    @Environment(DependencyContainer.self) private var container

    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            listContent
                .background(AppBackground())
                .scrollContentBackground(.hidden)
        }
    }

    private var listContent: some View {
        List {
                Section("Account") {
                    row(icon: "person.crop.circle", tint: AppShellTheme.accent, title: "Profile")
                    row(icon: "envelope", tint: AppShellTheme.accent, title: "Email & password")
                }

                Section("Plan") {
                    row(icon: "crown.fill", tint: AppShellTheme.gold, title: "Subscription")
                    row(icon: "creditcard", tint: AppShellTheme.accent, title: "Payment methods")
                }

                Section("Preferences") {
                    row(icon: "bell", tint: AppShellTheme.accent, title: "Notifications")
                }

                Section("About") {
                    row(icon: "lock.shield", tint: AppShellTheme.accent, title: "Privacy policy")
                    row(icon: "doc.text", tint: AppShellTheme.accent, title: "Terms of service")
                }

                Section {
                    Button(role: .destructive) {
                        Haptics.selection()
                        authStore.signOut()
                        dismiss()
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            appState.resetOnboarding()
                        }
                    } label: {
                        Text("Sign out")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    Button(role: .destructive) {
                        Haptics.feedback(style: .heavy)
                        showDeleteConfirm = true
                    } label: {
                        Text("Delete account")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppShellTheme.accent)
                }
            }
            .alert("Delete account?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { performDelete() }
            } message: {
                Text("This wipes your messages, your recipients, and your account on this device. You'll be taken back to the start.")
            }
    }

    private func performDelete() {
        Haptics.notification(type: .warning)
        // Defer so the sheet dismiss animation finishes before the root swaps
        // to onboarding; otherwise the swap happens behind the sheet.
        Task { @MainActor in
            try? await container.meRepository.deleteAccount()
            authStore.signOut()
            store.resetToSeed()
            dismiss()
            try? await Task.sleep(nanoseconds: 300_000_000)
            appState.resetOnboarding()
        }
    }

    private func row(icon: String, tint: Color, title: String) -> some View {
        Button {
            Haptics.selection()
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(tint)
                    .frame(width: 26)
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppShellTheme.subtitle)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
