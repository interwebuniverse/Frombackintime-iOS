//
//  MainComponents.swift
//  FromBackInTime
//
//  Shared building blocks for the main app screens: the icons8 template icon,
//  card surface, section header, empty state. Keeps the tab screens consistent.
//

import SwiftUI

// MARK: - Icon
// icons8 line icons (imported as template images) tinted to the accent so the
// whole app speaks one clean icon language. Use `AppIcon` instead of SF
// Symbols across the main shell.

struct AppIcon: View {
    let name: String
    var size: CGFloat = 22
    var color: Color = AppShellTheme.title

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}

// MARK: - Search field
// Custom search bar so it lives in the scroll content (not the iOS 26 nav bar),
// matching the app's rounded look with an icons8 magnifier.

struct AppSearchField: View {
    @Binding var text: String
    var prompt: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            AppIcon(name: "app-ic-search", size: 18, color: AppShellTheme.faint)
            TextField(
                "",
                text: $text,
                prompt: Text(prompt).foregroundColor(AppShellTheme.subtitle)
            )
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(AppShellTheme.title)
            .tint(AppShellTheme.accent)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 13)
        .background(.white.opacity(0.75), in: Capsule())
        .overlay(Capsule().strokeBorder(AppShellTheme.cardBorder, lineWidth: 1))
    }
}

// MARK: - Card surface

struct AppCard<Content: View>: View {
    var padding: CGFloat = AppSpacing.xl
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
                    .strokeBorder(AppShellTheme.cardBorder, lineWidth: 1)
            )
            .shadow(color: AppShellTheme.cardShadow, radius: 14, y: 6)
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppShellTheme.accent)
            }
        }
    }
}

// MARK: - Saving overlay
// A blocking veil shown while a message uploads + seals, so a large video never
// looks like a frozen "Saving…" button.

struct SavingOverlay: View {
    var message: String = "Sealing your message\u{2026}"
    var detail: String = "Hang tight, videos can take a moment."

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: AppSpacing.md) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
                Text(message)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.xxl)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
            .padding(AppSpacing.xxl)
        }
        .transition(.opacity)
    }
}

extension View {
    @ViewBuilder
    func savingOverlay(_ isActive: Bool, message: String = "Sealing your message\u{2026}", detail: String = "Hang tight, videos can take a moment.") -> some View {
        overlay {
            if isActive { SavingOverlay(message: message, detail: detail) }
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Loading state
// Shown on the very first load, before any data arrives, so a returning user
// with a full vault never sees a blank/empty screen while it fetches.

struct LoadingStateView: View {
    var message = "Loading your vault\u{2026}"

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(AppShellTheme.accent)
            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxxxl)
        .padding(.bottom, AppSpacing.xxxl)
    }
}

// MARK: - Load error state
// Shown when the first load failed and there's nothing to show. Distinct from an
// empty vault, and offers a retry rather than stranding the user.

struct LoadErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle().fill(Color.appError.opacity(0.12)).frame(width: 84, height: 84)
                AppIcon(name: "app-ic-inbox", size: 36, color: Color.appError)
            }
            .padding(.bottom, AppSpacing.xs)
            Text("We couldn't load your vault")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button("Try again", action: retry)
                .primaryButton()
                .padding(.top, AppSpacing.sm)
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    /// icons8 asset name (app-ic-*).
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppShellTheme.accentSoft)
                    .frame(width: 84, height: 84)
                AppIcon(name: icon, size: 38, color: AppShellTheme.accent)
            }
            .padding(.bottom, AppSpacing.xs)
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .primaryButton()
                    .padding(.top, AppSpacing.sm)
            }
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity)
    }
}
