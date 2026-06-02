//
//  IconPageView.swift
//  FromBackInTime
//
//  Screen 7 (Icon Page). The page for one person. Shows the messages
//  addressed to them, split into CTM and standard sections, with quick
//  actions to record more or to toggle a CTM's activation.
//

import SwiftUI

struct IconPageView: View {
    @Environment(MockAppStore.self) private var store
    let recipient: Recipient

    @State private var showCreate = false
    @State private var pendingKind: MessageKind = .standard
    @Namespace private var ns

    private var ctms: [Message] { store.ctmMessages(for: recipient.id) }
    private var standards: [Message] { store.standardMessages(for: recipient.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                header

                actions

                section(
                    title: "Critical Timed Messages",
                    icon: "shield.lefthalf.filled",
                    tint: AppShellTheme.gold,
                    items: ctms,
                    emptyText: "No CTM for \(recipient.name) yet."
                )

                section(
                    title: "Standard Messages",
                    icon: "paperplane.fill",
                    tint: AppShellTheme.accent,
                    items: standards,
                    emptyText: "Nothing scheduled for \(recipient.name) yet."
                )
            }
            .padding(.horizontal, AppShellTheme.screenPadding)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .background(AppBackground())
        .scrollContentBackground(.hidden)
        .navigationTitle(recipient.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreate) {
            CreateView(initialRecipient: recipient, initialKind: pendingKind)
                .presentationCornerRadius(28)
        }
        .navigationDestination(for: Message.self) { msg in
            MessageDetailView(message: msg)
                .navigationTransition(.zoom(sourceID: msg.id, in: ns))
        }
    }

    private var header: some View {
        HStack(spacing: AppSpacing.lg) {
            RecipientAvatar(recipient: recipient, size: 72)
            VStack(alignment: .leading, spacing: 2) {
                Text(recipient.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                if !recipient.relationship.isEmpty {
                    Text(recipient.relationship)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                }
                Text("\(standards.count) scheduled · \(ctms.count) CTM")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppShellTheme.accent)
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
    }

    private var actions: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                Haptics.selection()
                pendingKind = .standard
                showCreate = true
            } label: {
                actionLabel(icon: "paperplane.fill", title: "New message", tint: AppShellTheme.accent)
            }
            .buttonStyle(.plain)

            Button {
                Haptics.selection()
                pendingKind = .ctm
                showCreate = true
            } label: {
                actionLabel(icon: "shield.lefthalf.filled", title: "New CTM", tint: AppShellTheme.gold)
            }
            .buttonStyle(.plain)
        }
    }

    private func actionLabel(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
        .shadow(color: AppShellTheme.cardShadow, radius: 8, y: 3)
    }

    @ViewBuilder
    private func section(title: String, icon: String, tint: Color, items: [Message], emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
            }

            if items.isEmpty {
                AppCard {
                    Text(emptyText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                }
            } else {
                VStack(spacing: AppSpacing.md) {
                    ForEach(items) { msg in
                        NavigationLink(value: msg) {
                            Group {
                                if msg.kind == .ctm {
                                    CTMRow(message: msg)
                                } else {
                                    MessageRow(message: msg)
                                }
                            }
                            .matchedTransitionSource(id: msg.id, in: ns)
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
            }
        }
    }
}

struct CTMRow: View {
    @Environment(MockAppStore.self) private var store
    let message: Message

    var body: some View {
        AppCard(padding: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(AppShellTheme.gold)
                    Text(message.occasion)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppShellTheme.title)
                    Spacer()
                    Text(message.ctmActivated ? "Activated" : "Not activated")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(message.ctmActivated ? AppShellTheme.accent : AppShellTheme.subtitle.opacity(0.6))
                        )
                }
                if let d = message.deliveryDate {
                    Text("Projected release: \(DateFormatter.prettyDate.string(from: d))")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppShellTheme.accent)
                }
                Button {
                    Haptics.feedback(style: .medium)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                        store.toggleCTMActivation(id: message.id)
                    }
                } label: {
                    Text(message.ctmActivated ? "Deactivate" : "Activate CTM")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .fill(message.ctmActivated ? AppShellTheme.subtitle : AppShellTheme.gold)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
