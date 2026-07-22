//
//  SettingsView.swift
//  FromBackInTime
//
//  Reached from the gear in the top-right of every tab. Shows the account
//  (sign-in gate for anonymous vaults), app info, and the exits. Only rows
//  that actually do something are shown.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore
    @Environment(DependencyContainer.self) private var container

    @State private var showDeleteConfirm = false
    @State private var showSignIn = false
    @State private var deleteError: String?
    @State private var isDeleting = false

    private var isAnonymous: Bool { authStore.state.isAnonymous }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            AppNavScrollView(
                title: "Settings",
                trailing: .close { dismiss() },
                topInset: 10
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    sectionCard(title: "Account") {
                        accountRow
                    }

                    sectionCard(title: "About") {
                        linkRow(title: "Privacy Policy", systemImage: "lock.shield", url: "https://frombackintime.com/privacy")
                            .a11y("settings.privacy")
                        rowDivider
                        linkRow(title: "Terms of Service", systemImage: "doc.text", url: "https://frombackintime.com/terms")
                            .a11y("settings.terms")
                        rowDivider
                        linkRow(title: "Contact support", systemImage: "envelope", url: "mailto:support@frombackintime.com")
                            .a11y("settings.support")
                        rowDivider
                        versionRow
                    }

                    if !isAnonymous {
                        sectionCard(title: nil) {
                            Button {
                                performSignOut()
                            } label: {
                                dangerRow(title: "Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                            .buttonStyle(.plain)
                            .a11y("settings.signout")
                            rowDivider
                            Button {
                                Haptics.feedback(style: .heavy)
                                showDeleteConfirm = true
                            } label: {
                                dangerRow(title: isDeleting ? "Deleting\u{2026}" : "Delete account", systemImage: "trash")
                            }
                            .buttonStyle(.plain)
                            .disabled(isDeleting)
                            .a11y("settings.delete")
                        }
                    }
                }
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.bottom, AppSpacing.xxxl)
            }
            .a11y("settings.screen")
            .sheet(isPresented: $showSignIn) {
                SignInSheet(subtitle: "Sign in so your messages outlive this phone and no one else can ever claim them.")
            }
            .alert("Delete account?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { performDelete() }
            } message: {
                Text("This wipes your messages, your recipients, and your account. You'll be taken back to the start.")
            }
            .alert("Couldn't delete your account", isPresented: Binding(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteError ?? "")
            }
        }
    }

    // MARK: - Section pieces (white cards on the sky, List-free)

    @ViewBuilder
    private func sectionCard<C: View>(title: String?, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let title {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle)
                    .textCase(.uppercase)
                    .padding(.leading, AppSpacing.xs)
            }
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
                    .strokeBorder(AppShellTheme.cardBorder, lineWidth: 1)
            )
            .shadow(color: AppShellTheme.cardShadow, radius: 14, y: 6)
        }
    }

    private var rowDivider: some View {
        Divider()
            .overlay(AppShellTheme.cardBorder)
            .padding(.leading, AppSpacing.lg + 26 + AppSpacing.md)
    }

    private var accountRow: some View {
        Group {
            if isAnonymous {
                Button {
                    Haptics.selection()
                    showSignIn = true
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppShellTheme.accent)
                            .frame(width: 26)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sign in")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppShellTheme.title)
                            Text("Protect your vault so it outlives this phone.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppShellTheme.subtitle)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppShellTheme.subtitle)
                    }
                    .padding(AppSpacing.lg)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppShellTheme.accent)
                        .frame(width: 26)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(authStore.state.profileName ?? "Signed in")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                        Text(authStore.state.email ?? "Your vault is tied to your account.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppShellTheme.subtitle)
                    }
                    Spacer(minLength: 0)
                }
                .padding(AppSpacing.lg)
            }
        }
    }

    private var versionRow: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppShellTheme.accent)
                .frame(width: 26)
            Text("Version")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
            Spacer()
            Text(appVersion)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
        }
        .padding(AppSpacing.lg)
    }

    private func dangerRow(title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.appError)
                .frame(width: 26)
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appError)
            Spacer()
        }
        .padding(AppSpacing.lg)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func linkRow(title: String, systemImage: String, url: String) -> some View {
        if let link = URL(string: url) {
            Link(destination: link) {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppShellTheme.accent)
                        .frame(width: 26)
                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.title)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppShellTheme.subtitle)
                }
                .padding(AppSpacing.lg)
                .contentShape(Rectangle())
            }
        }
    }

    private func performSignOut() {
        Haptics.selection()
        dismiss()
        // signOut mints a fresh anonymous session and posts sessionReplaced,
        // which reloads the app store, so nothing of the old vault lingers. We
        // leave the user in the app (anonymous) rather than throwing them back
        // through the whole onboarding story; they can sign in again from here.
        Task { @MainActor in
            await authStore.signOut()
        }
    }

    private func performDelete() {
        Haptics.notification(type: .warning)
        isDeleting = true
        Task { @MainActor in
            defer { isDeleting = false }
            do {
                try await container.meRepository.deleteAccount()
            } catch {
                // Keep the account state as-is; signing the user out anyway
                // would fake a deletion that never happened.
                deleteError = error.localizedDescription
                return
            }
            await authStore.signOut()
            store.resetToSeed()
            dismiss()
            // Defer so the sheet dismiss animation finishes before the root
            // swaps to onboarding; otherwise the swap happens behind the sheet.
            try? await Task.sleep(nanoseconds: 300_000_000)
            appState.resetOnboarding()
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
