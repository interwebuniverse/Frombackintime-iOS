//
//  AppNavScrollView.swift
//  FromBackInTime
//
//  Base scroll view with a large title that shrinks into a compact top bar on
//  scroll (like the native large-title bar, but self-contained so it works
//  anywhere, including inside a tab). The compact bar sits on a soft glass
//  fade so the sky and content melt under it instead of hitting a hard edge,
//  and it looks the same on every iOS version. Circular glass buttons replace
//  the system toolbar, which stays hidden on every screen that uses this.
//

import SwiftUI

private let navBarHeight: CGFloat = 48
private let largeTitleSize: CGFloat = 34

/// A top-bar action: an icons8 glyph (app-ic-*) or SF Symbol name + label +
/// tap handler. Names without the "app-" prefix render as SF Symbols.
struct AppNavAction {
    let icon: String
    let label: String
    var tint: Color = AppShellTheme.accent
    let action: () -> Void

    static func back(_ action: @escaping () -> Void) -> AppNavAction {
        AppNavAction(icon: "chevron.left", label: "Back", tint: AppShellTheme.title, action: action)
    }

    static func close(_ action: @escaping () -> Void) -> AppNavAction {
        AppNavAction(icon: "xmark", label: "Close", tint: AppShellTheme.title, action: action)
    }
}

struct AppNavScrollView<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var leading: AppNavAction? = nil
    var trailing: AppNavAction? = nil
    /// Sheets pass a small inset so the header isn't stuck to the top edge.
    var topInset: CGFloat = 0
    var searchText: Binding<String>? = nil
    var searchPrompt: String = ""
    var onRefresh: (() async -> Void)? = nil
    @ViewBuilder let content: Content

    @State private var compact = false
    @State private var titleHeight = CGFloat.zero
    @State private var headerHeight = CGFloat.zero
    @State private var titleFontSize = largeTitleSize

    var body: some View {
        scroll
            .scrollIndicators(.hidden)
            .contentMargins(.top, navBarHeight + topInset, for: .scrollContent)
            .background(AppBackground())
            .overlay(alignment: .top) { compactBar }
            .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var scroll: some View {
        if let onRefresh {
            scrollBody.refreshable { await onRefresh() }
        } else {
            scrollBody
        }
    }

    private var scrollBody: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                content
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.frame(in: .scrollView).minY
                    } action: { newValue in
                        Execute.async {
                            let offset = newValue - headerHeight
                            compact = offset < -titleHeight
                            // Base 34; overscroll grows it a touch, like the
                            // native large title.
                            titleFontSize = max(largeTitleSize, min(largeTitleSize + 4, largeTitleSize + (offset - navBarHeight) / 18))
                        }
                    }
            }
        }
    }

    // MARK: Compact bar

    private var compactBar: some View {
        ZStack {
            HStack(spacing: AppSpacing.sm) {
                if let leading { navButton(leading) }
                Spacer(minLength: 0)
                if let trailing { navButton(trailing) }
            }
            .padding(.horizontal, AppShellTheme.screenPadding)

            if compact {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 64)
                    .transition(.move(edge: .bottom).combined(with: .blurReplace))
            }
        }
        .padding(.top, topInset)
        .frame(maxWidth: .infinity)
        .frame(height: navBarHeight + topInset, alignment: .bottom)
        .background(fade)
        .animation(.bouncy(duration: 0.3), value: compact)
    }

    /// Circular glass button, same feel on iOS 17 and the new glass toolbars.
    private func navButton(_ item: AppNavAction) -> some View {
        Button {
            Haptics.selection()
            item.action()
        } label: {
            Group {
                if item.icon.hasPrefix("app-") {
                    AppIcon(name: item.icon, size: 20, color: item.tint)
                } else {
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(item.tint)
                }
            }
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial, in: Circle())
                .background(Circle().fill(.white.opacity(0.55)))
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
                .shadow(color: AppShellTheme.cardShadow, radius: 10, y: 4)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
    }

    /// Soft glass fade: a material masked top-to-transparent, with a faint sky
    /// tint for legibility. Content melts under the bar with no hard band.
    private var fade: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            LinearGradient(
                colors: [Color.white.opacity(0.72), Color.white.opacity(0.0)],
                startPoint: .top, endPoint: .bottom
            )
        }
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0.0),
                    .init(color: .black, location: 0.62),
                    .init(color: .black.opacity(0.7), location: 0.84),
                    .init(color: .clear, location: 1.0),
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .top)
    }

    // MARK: Large title header (scrolls away)

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { newValue in
                    Execute.async { titleHeight = newValue }
                }
                .opacity(compact ? 0 : 1)
                .blur(radius: compact ? 5 : 0)
                .animation(.bouncy(duration: 0.3), value: compact)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let searchText {
                AppSearchField(text: searchText, prompt: searchPrompt)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .padding(.horizontal, AppShellTheme.screenPadding)
        .padding(.top, AppSpacing.xs)
        .padding(.bottom, AppSpacing.md)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newValue in
            Execute.async { headerHeight = newValue }
        }
    }
}

// MARK: - Sheet header

/// Header for sheets whose body is a List or form (no scroll-shrink): the same
/// big rounded title and circular glass buttons as AppNavScrollView, so every
/// surface in the app opens with the same face. Hide the system bar and put
/// this at the top.
struct AppSheetHeader: View {
    let title: String
    var leading: AppNavAction? = nil
    var trailing: AppNavAction? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                if let leading { button(leading) }
                Spacer(minLength: 0)
                if let trailing { button(trailing) }
            }
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, AppShellTheme.screenPadding)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xs)
    }

    private func button(_ item: AppNavAction) -> some View {
        Button {
            Haptics.selection()
            item.action()
        } label: {
            Group {
                if item.icon.hasPrefix("app-") {
                    AppIcon(name: item.icon, size: 20, color: item.tint)
                } else {
                    Image(systemName: item.icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(item.tint)
                }
            }
            .frame(width: 38, height: 38)
            .background(.ultraThinMaterial, in: Circle())
            .background(Circle().fill(.white.opacity(0.55)))
            .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
            .shadow(color: AppShellTheme.cardShadow, radius: 8, y: 3)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
    }
}
