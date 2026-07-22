//
//  HomeView.swift
//  FromBackInTime
//
//  Dashboard. A warm greeting, a spotlight on the next message to arrive,
//  quick stats, the CTM check-in, ideas to record, your people, and the
//  upcoming feed. Built to feel alive and personal, not a bare list.
//

import SwiftUI

struct HomeView: View {
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore
    @Namespace private var ns

    @State private var isCheckingIn = false
    @State private var justCheckedIn = false
    @State private var showCreate = false
    @State private var createKind: MessageKind = .standard

    var body: some View {
        AppScreen(title: greetingTitle, onRefresh: { await store.load() }) {
            Group {
                if store.isInitialLoading {
                    LoadingStateView()
                        .padding(.top, AppSpacing.xxxxl)
                } else {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        loadErrorCard
                        spotlight
                        statsRow
                        if store.hasArmedCTM { ctmCheckInCard }
                        ideasSection
                        peopleStrip
                        upcomingSection
                    }
                    .padding(.horizontal, AppShellTheme.screenPadding)
                    .padding(.top, AppSpacing.xs)
                    .padding(.bottom, AppSpacing.xxxl)
                    .animation(.spring(response: 0.4, dampingFraction: 0.78), value: store.messages.count)
                    .animation(.spring(response: 0.4, dampingFraction: 0.78), value: store.recipients.count)
                }
            }
            .sheet(isPresented: $showCreate) {
                CreateView(initialKind: createKind)
                    .presentationCornerRadius(28)
            }
            .navigationDestination(for: Recipient.self) { recipient in
                IconPageView(recipient: recipient)
                    .navigationTransition(.zoom(sourceID: recipient.id, in: ns))
            }
            .navigationDestination(for: Message.self) { msg in
                MessageDetailView(message: msg)
                    .navigationTransition(.zoom(sourceID: msg.id, in: ns))
            }
            .a11y("home.screen")
        }
    }

    private var greetingTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let base: String
        switch hour {
        case 5..<12:  base = "Good morning"
        case 12..<17: base = "Good afternoon"
        case 17..<22: base = "Good evening"
        default:      base = "Hello"
        }
        if let name = authStore.state.profileName?.trimmingCharacters(in: .whitespaces), !name.isEmpty {
            return "\(base), \(name)"
        }
        return base
    }

    // MARK: - Spotlight (next message, or an invite to start)

    @ViewBuilder
    private var spotlight: some View {
        if let next = store.upcoming(limit: 1).first, let recipient = store.recipient(id: next.recipientID) {
            NavigationLink(value: next) {
                spotlightCard(next, recipient)
                    .matchedTransitionSource(id: next.id, in: ns)
            }
            .buttonStyle(.pressableCard)
            .a11y("home.next.card")
        } else {
            inviteCard
        }
    }

    private func spotlightCard(_ msg: Message, _ recipient: Recipient) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack {
                Text("YOUR NEXT MESSAGE")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
                HStack(spacing: 5) {
                    AppIcon(name: msg.medium.glyph, size: 12, color: .white)
                    Text(msg.medium.shortLabel)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Capsule().fill(.white.opacity(0.22)))
            }

            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle().fill(.white.opacity(0.25)).frame(width: 52, height: 52)
                    Text(recipient.initials)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("To \(recipient.name)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(msg.occasion.isEmpty ? "A message forward in time" : msg.occasion)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: AppSpacing.sm) {
                AppIcon(name: "app-ic-clock", size: 15, color: .white)
                Text(countdownText(to: msg.deliveryDate))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                AppIcon(name: "app-ic-chevron", size: 14, color: .white.opacity(0.9))
            }
            .padding(.top, 2)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppShellTheme.accent, AppShellTheme.accent.opacity(0.82)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
        )
        .shadow(color: AppShellTheme.accent.opacity(0.28), radius: 18, y: 9)
    }

    private var inviteCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Send something forward")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Record a message today and we'll deliver it exactly when it should arrive, even years from now.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            Button {
                Haptics.selection()
                createKind = .standard
                showCreate = true
            } label: {
                HStack(spacing: 6) {
                    AppIcon(name: "app-ic-plus", size: 16, color: AppShellTheme.accent)
                    Text("Record a message")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppShellTheme.accent)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm + 2)
                .background(Capsule().fill(.white))
            }
            .buttonStyle(.plain)
            .a11y("home.empty.cta")
            .padding(.top, 2)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppShellTheme.accent, AppShellTheme.accent.opacity(0.82)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
        )
        .shadow(color: AppShellTheme.accent.opacity(0.28), radius: 18, y: 9)
    }

    private func countdownText(to date: Date?) -> String {
        guard let date else { return "Awaiting a delivery date" }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()),
                                                   to: Calendar.current.startOfDay(for: date)).day ?? 0
        let when: String
        switch days {
        case ..<0:   when = "Delivering now"
        case 0:      when = "Delivers today"
        case 1:      when = "Delivers tomorrow"
        case 2..<45: when = "In \(days) days"
        default:
            let months = max(1, Int((Double(days) / 30.4).rounded()))
            if months < 12 {
                when = months == 1 ? "In 1 month" : "In \(months) months"
            } else {
                let years = Double(days) / 365.0
                when = years < 1.05 ? "In about a year" : "In \(String(format: "%.1f", years)) years"
            }
        }
        return "\(when) · \(DateFormatter.prettyDateTime.string(from: date))"
    }

    // MARK: - Load error

    @ViewBuilder
    private var loadErrorCard: some View {
        if let error = store.error {
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(error)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appError)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Try again") {
                        Haptics.selection()
                        store.error = nil
                        Task { await store.load() }
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppShellTheme.accent)
                }
            }
        }
    }

    // MARK: - CTM check-in (the "I'm alive" loop)

    private var ctmCheckInCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle().fill(AppShellTheme.goldSoft).frame(width: 40, height: 40)
                        AppIcon(name: "app-ic-shield", size: 20, color: AppShellTheme.gold)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(justCheckedIn ? "All reset. See you soon." : "Your switch is armed")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                        Text(ctmSubtitle)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppShellTheme.subtitle)
                    }
                }

                if !justCheckedIn {
                    HStack(spacing: AppSpacing.md) {
                        Button {
                            performCTM { await store.checkIn() }
                        } label: {
                            Text(isCheckingIn ? "One sec\u{2026}" : "I'm here")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm + 2)
                                .background(Capsule().fill(AppShellTheme.accent))
                        }
                        .buttonStyle(.plain)

                        Button {
                            performCTM { await store.snooze() }
                        } label: {
                            Text("Snooze 7 days")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppShellTheme.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm + 2)
                                .background(Capsule().strokeBorder(AppShellTheme.accent.opacity(0.5), lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                    .disabled(isCheckingIn)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: justCheckedIn)
        .a11y("home.ctm.card")
    }

    private var ctmSubtitle: String {
        if justCheckedIn {
            return "Your critical messages stay sealed."
        }
        if let next = store.nextCTMDate {
            return "Check in to keep them sealed. Next check-in by \(DateFormatter.prettyDate.string(from: next))."
        }
        return "Check in regularly to keep your critical messages sealed."
    }

    private func performCTM(_ op: @escaping () async -> Bool) {
        guard !isCheckingIn else { return }
        isCheckingIn = true
        Task {
            let ok = await op()
            isCheckingIn = false
            guard ok else {
                Haptics.notification(type: .error)
                return
            }
            Haptics.notification(type: .success)
            justCheckedIn = true
            try? await Task.sleep(for: .seconds(3))
            justCheckedIn = false
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            statTile(value: store.standardMessages().count, label: "Scheduled",
                     icon: "app-ic-send", tint: AppShellTheme.accent)
            statTile(value: store.ctmMessages().count, label: "CTM ready",
                     icon: "app-ic-shield", tint: AppShellTheme.gold)
            statTile(value: store.recipients.count, label: "People",
                     icon: "app-ic-people", tint: AppShellTheme.accent)
        }
    }

    private func statTile(value: Int, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle().fill(tint.opacity(0.12)).frame(width: 40, height: 40)
                AppIcon(name: icon, size: 20, color: tint)
            }
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .contentTransition(.numericText(value: Double(value)))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
                .strokeBorder(AppShellTheme.cardBorder, lineWidth: 1)
        )
        .shadow(color: AppShellTheme.cardShadow, radius: 12, y: 5)
    }

    // MARK: - Ideas to record

    private var ideasSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Ideas to record")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(HomeIdea.all) { idea in
                        Button {
                            Haptics.selection()
                            createKind = idea.kind
                            showCreate = true
                        } label: {
                            ideaCard(idea)
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func ideaCard(_ idea: HomeIdea) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack {
                Circle().fill(idea.tint.opacity(0.14)).frame(width: 42, height: 42)
                AppIcon(name: idea.icon, size: 22, color: idea.tint)
            }
            Spacer(minLength: AppSpacing.sm)
            Text(idea.title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 132, height: 132, alignment: .topLeading)
        .padding(AppSpacing.lg)
        .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
                .strokeBorder(AppShellTheme.cardBorder, lineWidth: 1)
        )
        .shadow(color: AppShellTheme.cardShadow, radius: 12, y: 5)
    }

    // MARK: - People strip

    @ViewBuilder
    private var peopleStrip: some View {
        if store.recipients.isEmpty {
            EmptyView()
        } else {
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
                        .a11y("person.row")
                    }
                }
                .padding(.horizontal, AppSpacing.xs)
            }
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

// MARK: - Idea model

private struct HomeIdea: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: String
    let kind: MessageKind

    static let all: [HomeIdea] = [
        .init(icon: "app-ic-heart", tint: Color(hue: 0.95, saturation: 0.6, brightness: 0.9),
              title: "Just say\nI love you", kind: .standard),
        .init(icon: "app-ic-calendar", tint: AppShellTheme.accent,
              title: "A birthday,\nyears ahead", kind: .standard),
        .init(icon: "app-ic-clock", tint: AppShellTheme.gold,
              title: "Open this\nin 10 years", kind: .standard),
        .init(icon: "app-ic-edit", tint: Color(hue: 0.36, saturation: 0.55, brightness: 0.65),
              title: "Advice &\nlife lessons", kind: .standard),
        .init(icon: "app-ic-shield", tint: AppShellTheme.gold,
              title: "Passwords\n& final wishes", kind: .ctm),
    ]
}

#Preview {
    HomeView()
        .environment(MockAppStore())
        .environment(AppState())
}
