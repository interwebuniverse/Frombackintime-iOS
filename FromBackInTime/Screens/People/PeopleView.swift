//
//  PeopleView.swift
//  FromBackInTime
//
//  Recipient icon grid. Each tile zooms (iOS 18 navigation zoom transition)
//  into the matching Icon Page. Searchable by name or relationship.
//

import SwiftUI

struct PeopleView: View {
    @Environment(MockAppStore.self) private var store
    @Namespace private var ns
    @State private var showAddPerson = false
    @State private var query: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.lg),
        GridItem(.flexible(), spacing: AppSpacing.lg),
        GridItem(.flexible(), spacing: AppSpacing.lg)
    ]

    private var filtered: [Recipient] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return store.recipients }
        return store.recipients.filter {
            $0.name.lowercased().contains(q) || $0.relationship.lowercased().contains(q)
        }
    }

    var body: some View {
        AppScreen(title: "People") {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppSpacing.xl) {
                    ForEach(filtered) { recipient in
                        NavigationLink(value: recipient) {
                            PersonTile(recipient: recipient, messageCount: messageCount(for: recipient))
                                .matchedTransitionSource(id: recipient.id, in: ns)
                        }
                        .buttonStyle(.pressableCard)
                    }
                    if query.isEmpty { addTile }
                }
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.xxxl)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: filtered)
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search people")
            .navigationDestination(for: Recipient.self) { recipient in
                IconPageView(recipient: recipient)
                    .navigationTransition(.zoom(sourceID: recipient.id, in: ns))
            }
            .sheet(isPresented: $showAddPerson) {
                AddPersonView()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(28)
            }
        }
    }

    private func messageCount(for recipient: Recipient) -> Int {
        store.messages.filter { $0.recipientID == recipient.id }.count
    }

    private var addTile: some View {
        Button {
            Haptics.selection()
            showAddPerson = true
        } label: {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                        .foregroundStyle(AppShellTheme.accent.opacity(0.6))
                        .frame(width: 56, height: 56)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(AppShellTheme.accent)
                }
                Text("Add")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                Text(" ")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
        }
        .buttonStyle(.pressableCard)
    }
}

struct PersonTile: View {
    let recipient: Recipient
    let messageCount: Int

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            RecipientAvatar(recipient: recipient, size: 56)
            Text(recipient.name)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .lineLimit(1)
            Text(messageCount == 0 ? "No messages" : "\(messageCount) message\(messageCount == 1 ? "" : "s")")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }
}

#Preview {
    PeopleView()
        .environment(MockAppStore())
        .environment(AppState())
}
