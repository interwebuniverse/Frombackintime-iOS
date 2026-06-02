//
//  MainComponents.swift
//  FromBackInTime
//
//  Shared building blocks for the main app screens: card surface, section
//  header, empty state. Keeps the tab screens consistent.
//

import SwiftUI

// MARK: - Card surface

struct AppCard<Content: View>: View {
    var padding: CGFloat = AppSpacing.xl
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
            .shadow(color: AppShellTheme.cardShadow, radius: 12, y: 5)
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
                .font(.system(size: 18, weight: .bold, design: .rounded))
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

// MARK: - Empty state

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppShellTheme.accent)
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
