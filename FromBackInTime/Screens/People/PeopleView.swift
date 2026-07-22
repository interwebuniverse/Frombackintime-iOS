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
    @State private var editingPerson: Recipient?
    @State private var deletingPerson: Recipient?
    @State private var deleteError: String?
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
        AppScreen(
            title: "People",
            searchText: $query,
            searchPrompt: "Search people",
            onRefresh: { await store.load() }
        ) {
            Group {
            if store.isInitialLoading {
                LoadingStateView(message: "Loading your people\u{2026}")
                    .padding(.top, AppSpacing.xxxxl)
            } else {
                if let error = store.error, store.recipients.isEmpty {
                    LoadErrorView(message: error) {
                        Haptics.selection()
                        store.error = nil
                        Task { await store.load() }
                    }
                    .padding(.horizontal, AppShellTheme.screenPadding)
                    .padding(.top, AppSpacing.xxxl)
                } else if !query.isEmpty, filtered.isEmpty {
                    EmptyStateView(
                        icon: "app-ic-search",
                        title: "No matches",
                        message: "No one by that name or relationship. Try another search."
                    )
                    .padding(.top, AppSpacing.xxxl)
                } else {
                LazyVGrid(columns: columns, spacing: AppSpacing.xl) {
                    ForEach(filtered) { recipient in
                        NavigationLink(value: recipient) {
                            PersonTile(recipient: recipient, messageCount: messageCount(for: recipient))
                                .matchedTransitionSource(id: recipient.id, in: ns)
                        }
                        .buttonStyle(.pressableCard)
                        .contextMenu {
                            Button {
                                editingPerson = recipient
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                deletingPerson = recipient
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    if query.isEmpty { addTile }
                }
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.xxxl)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: filtered)
                }
            }
            }
            .navigationDestination(for: Recipient.self) { recipient in
                IconPageView(recipient: recipient)
                    .navigationTransition(.zoom(sourceID: recipient.id, in: ns))
            }
            .sheet(isPresented: $showAddPerson) {
                AddPersonView()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(28)
            }
            .sheet(item: $editingPerson) { person in
                AddPersonView(editing: person)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(28)
            }
            .alert(
                "Delete \(deletingPerson?.name ?? "this person")?",
                isPresented: Binding(
                    get: { deletingPerson != nil },
                    set: { if !$0 { deletingPerson = nil } }
                ),
                presenting: deletingPerson
            ) { person in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { performDelete(person) }
            } message: { person in
                Text("Messages already written to \(person.name) stay in your library.")
            }
            .alert("Couldn't delete", isPresented: Binding(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteError ?? "")
            }
            .a11y("people.screen")
        }
    }

    private func performDelete(_ person: Recipient) {
        Task {
            if await store.deleteRecipient(id: person.id) {
                Haptics.notification(type: .success)
            } else {
                // Most likely the backend 409: they still have scheduled or
                // armed messages, which must be canceled first.
                Haptics.notification(type: .error)
                deleteError = store.error ?? "Something went wrong. Please try again."
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
                AppIcon(name: "app-ic-plus", size: 56, color: AppShellTheme.accent)
                    .frame(width: 56, height: 56)
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
        .a11y("people.empty.cta")
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
        .a11y("person.row")
    }
}

#Preview {
    PeopleView()
        .environment(MockAppStore())
        .environment(AppState())
}
