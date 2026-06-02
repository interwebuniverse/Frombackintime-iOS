//
//  HomeView.swift
//  FromBackInTime
//
//  Dashboard. Stats counters with numeric transitions, a horizontal people
//  strip and upcoming feed - both zoom-transition sources for their detail
//  views.
//

import SwiftUI

struct HomeView: View {
    @Environment(MockAppStore.self) private var store
    @Namespace private var ns

    var body: some View {
        AppScreen(title: "Home") {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    statsRow
                    peopleStrip
                    upcomingSection
                }
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.xxxl)
                .animation(.spring(response: 0.4, dampingFraction: 0.78), value: store.messages.count)
                .animation(.spring(response: 0.4, dampingFraction: 0.78), value: store.recipients.count)
            }
            .navigationDestination(for: Recipient.self) { recipient in
                IconPageView(recipient: recipient)
                    .navigationTransition(.zoom(sourceID: recipient.id, in: ns))
            }
            .navigationDestination(for: Message.self) { msg in
                MessageDetailView(message: msg)
                    .navigationTransition(.zoom(sourceID: msg.id, in: ns))
            }
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            statTile(value: store.standardMessages().count, label: "Scheduled",
                     icon: "paperplane.fill", tint: AppShellTheme.accent)
            statTile(value: store.ctmMessages().count, label: "CTM ready",
                     icon: "shield.lefthalf.filled", tint: AppShellTheme.gold)
            statTile(value: store.recipients.count, label: "People",
                     icon: "person.2.fill", tint: AppShellTheme.accent)
        }
    }

    private func statTile(value: Int, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
            Text("\(value)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .contentTransition(.numericText(value: Double(value)))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
        .shadow(color: AppShellTheme.cardShadow, radius: 10, y: 4)
    }

    // MARK: - People strip

    private var peopleStrip: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Your people")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.lg) {
                    ForEach(store.recipients) { recipient in
                        NavigationLink(value: recipient) {
                            VStack(spacing: AppSpacing.xs) {
                                RecipientAvatar(recipient: recipient, size: 64)
                                    .matchedTransitionSource(id: recipient.id, in: ns)
                                Text(recipient.name)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppShellTheme.title)
                            }
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
                .padding(.horizontal, AppSpacing.xs)
            }
        }
    }

    // MARK: - Upcoming

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Upcoming deliveries")
            let upcoming = store.upcoming(limit: 5)
            if upcoming.isEmpty {
                AppCard {
                    Text("Nothing scheduled in the next year.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                }
            } else {
                VStack(spacing: AppSpacing.md) {
                    ForEach(upcoming) { msg in
                        NavigationLink(value: msg) {
                            MessageRow(message: msg)
                                .matchedTransitionSource(id: msg.id, in: ns)
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(MockAppStore())
        .environment(AppState())
}
