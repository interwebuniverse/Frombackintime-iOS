//
//  LibraryView.swift
//  FromBackInTime
//
//  All messages. Two sections (CTM + Standard). Searchable, filterable, with
//  zoom transitions into the message detail.
//

import SwiftUI

struct LibraryView: View {
    @Environment(MockAppStore.self) private var store
    @State private var filter: LibraryFilter = .all
    @State private var query: String = ""
    @Namespace private var ns

    private var ctms: [Message] { filterRows(store.ctmMessages()) }
    private var standards: [Message] { filterRows(store.standardMessages()) }

    private func filterRows(_ rows: [Message]) -> [Message] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return rows }
        return rows.filter { msg in
            let name = store.recipient(id: msg.recipientID)?.name.lowercased() ?? ""
            return name.contains(q) ||
                   msg.occasion.lowercased().contains(q) ||
                   msg.bodyText.lowercased().contains(q)
        }
    }

    var body: some View {
        AppScreen(
            title: "Library",
            searchText: $query,
            searchPrompt: "Search messages",
            onRefresh: { await store.load() }
        ) {
            Group {
            if store.isInitialLoading {
                LoadingStateView(message: "Loading your messages\u{2026}")
                    .padding(.top, AppSpacing.xxxxl)
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    filterBar
                    if let error = store.error, ctms.isEmpty, standards.isEmpty, query.isEmpty {
                        LoadErrorView(message: error) {
                            Haptics.selection()
                            store.error = nil
                            Task { await store.load() }
                        }
                        .padding(.top, AppSpacing.xxxxl)
                    } else {
                        if filter != .standard, !ctms.isEmpty {
                            section(
                                title: "Critical Timed Messages",
                                icon: "app-ic-shield",
                                tint: AppShellTheme.gold,
                                items: ctms
                            )
                        }
                        if filter != .ctm, !standards.isEmpty {
                            section(
                                title: "Standard Messages",
                                icon: "app-ic-send",
                                tint: AppShellTheme.accent,
                                items: standards
                            )
                        }
                        if ctms.isEmpty && standards.isEmpty {
                            EmptyStateView(
                                icon: query.isEmpty ? "app-ic-inbox" : "app-ic-search",
                                title: query.isEmpty ? "Your library is empty" : "No matches",
                                message: query.isEmpty
                                    ? "Every message you record shows up here, with who it's for and when it sends."
                                    : "Try a different name, occasion, or word."
                            )
                            .padding(.top, AppSpacing.xxxxl)
                        }
                    }
                }
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.xxxl)
                .animation(.spring(response: 0.4, dampingFraction: 0.78), value: filter)
                .animation(.easeOut(duration: 0.2), value: query)
            }
            }
            .navigationDestination(for: Message.self) { msg in
                MessageDetailView(message: msg)
                    .navigationTransition(.zoom(sourceID: msg.id, in: ns))
            }
            .a11y("library.screen")
        }
    }

    private var filterBar: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(LibraryFilter.allCases, id: \.self) { f in
                Button {
                    Haptics.selection()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { filter = f }
                } label: {
                    Text(f.label)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(filter == f ? .white : AppShellTheme.title)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(filter == f ? AppShellTheme.accent : .white.opacity(0.7))
                        )
                        .overlay(
                            Capsule().strokeBorder(AppShellTheme.subtitle.opacity(filter == f ? 0 : 0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func section(title: String, icon: String, tint: Color, items: [Message]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                AppIcon(name: icon, size: 17, color: tint)
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                Text("\(items.count)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.faint)
                    .contentTransition(.numericText(value: Double(items.count)))
            }
            VStack(spacing: AppSpacing.md) {
                ForEach(items) { msg in
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

enum LibraryFilter: CaseIterable {
    case all, standard, ctm
    var label: String {
        switch self {
        case .all: return "All"
        case .standard: return "Scheduled"
        case .ctm: return "CTM"
        }
    }
}
