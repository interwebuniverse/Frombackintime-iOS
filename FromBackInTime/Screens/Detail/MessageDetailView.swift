//
//  MessageDetailView.swift
//  FromBackInTime
//
//  Detail view for a single message. Zoom-transition destination from any
//  message row. Shows a medium-specific hero (video poster, waveform, photo
//  card, or written body), with metadata and quick actions.
//

import SwiftUI

struct MessageDetailView: View {
    @Environment(MockAppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let message: Message

    @State private var playProgress: CGFloat = 0
    @State private var ticker: Timer?

    private var recipient: Recipient? { store.recipient(id: message.recipientID) }
    private var tint: Color { Color(hue: message.medium.hue, saturation: 0.62, brightness: 0.7) }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                hero
                metadata
                actions
            }
            .padding(.horizontal, AppShellTheme.screenPadding)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .background(AppBackground())
        .scrollContentBackground(.hidden)
        .navigationTitle(message.occasion)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { ticker?.invalidate() }
    }

    // MARK: - Hero

    @ViewBuilder
    private var hero: some View {
        switch message.medium {
        case .video: videoHero
        case .voice: voiceHero
        case .photo: photoHero
        case .text:  textHero
        }
    }

    private var videoHero: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 18/255, green: 22/255, blue: 36/255),
                         tint],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            if let recipient {
                Text(recipient.initials)
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.18))
            }
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text(durationLabel)
                        .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(.black.opacity(0.45)))
                .padding(AppSpacing.md)
            }
        }
        .aspectRatio(9/12, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(color: tint.opacity(0.25), radius: 18, y: 8)
    }

    private var voiceHero: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                LinearGradient(
                    colors: [tint.opacity(0.85), Color(hue: message.medium.hue, saturation: 0.4, brightness: 0.95)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                voiceBars
                    .padding(.horizontal, AppSpacing.xl)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .shadow(color: tint.opacity(0.3), radius: 16, y: 8)

            HStack {
                Text(timeLabel(progress: playProgress))
                    .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
                Spacer()
                Text(durationLabel)
                    .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
            }
            .foregroundStyle(AppShellTheme.subtitle)

            playButton
        }
    }

    private var voiceBars: some View {
        TimelineView(.animation(minimumInterval: 1.0/30.0)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let bars = 28
                let midY = size.height / 2
                for i in 0..<bars {
                    let phase = Double(i) * 0.34
                    let amp = 8 + 22 * abs(sin(t * 2 + phase)) + 12 * abs(sin(t * 5 + phase * 1.5))
                    let x = (CGFloat(i) + 0.5) * (size.width / CGFloat(bars))
                    let rect = CGRect(x: x - 2, y: midY - amp, width: 4, height: amp * 2)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(.white.opacity(0.85)))
                }
            }
        }
    }

    private var photoHero: some View {
        VStack(spacing: 0) {
            ZStack {
                if let recipient {
                    LinearGradient(
                        colors: [recipient.avatarColor, recipient.avatarColor.opacity(0.55)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 88, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                        .offset(x: 70, y: -50)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            if !message.bodyText.isEmpty {
                Text(message.bodyText)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.lg)
                    .background(.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
    }

    private var textHero: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(systemName: "quote.opening")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(tint)
            Text(message.bodyText.isEmpty ? "(no body)" : message.bodyText)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .lineSpacing(4)
                .foregroundStyle(AppShellTheme.title)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppSpacing.xl)
        .background(.white, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
    }

    // MARK: - Metadata + actions

    private var metadata: some View {
        VStack(spacing: AppSpacing.md) {
            if let recipient {
                AppCard {
                    HStack(spacing: AppSpacing.md) {
                        RecipientAvatar(recipient: recipient, size: 44)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("To \(recipient.name)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(AppShellTheme.title)
                            if !recipient.relationship.isEmpty {
                                Text(recipient.relationship)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppShellTheme.subtitle)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            }

            HStack(spacing: AppSpacing.md) {
                infoChip(icon: message.medium.icon, label: message.medium.shortLabel, tint: tint)
                if message.kind == .ctm {
                    infoChip(icon: "shield.lefthalf.filled",
                             label: message.ctmActivated ? "CTM activated" : "CTM standby",
                             tint: AppShellTheme.gold)
                }
                if let d = message.deliveryDate {
                    infoChip(icon: "calendar",
                             label: DateFormatter.prettyDate.string(from: d),
                             tint: AppShellTheme.accent)
                }
            }
        }
    }

    private func infoChip(icon: String, label: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(tint.opacity(0.14)))
    }

    private var actions: some View {
        VStack(spacing: AppSpacing.md) {
            if message.kind == .ctm {
                Button {
                    Haptics.feedback(style: .medium)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                        store.toggleCTMActivation(id: message.id)
                    }
                } label: {
                    Text(message.ctmActivated ? "Deactivate CTM" : "Activate CTM")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .fill(message.ctmActivated ? AppShellTheme.subtitle : AppShellTheme.gold)
                        )
                }
                .buttonStyle(.pressableCard)
            }

            Button(role: .destructive) {
                Haptics.notification(type: .warning)
                store.deleteMessage(id: message.id)
                dismiss()
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "trash")
                    Text("Delete message")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(Color.red.opacity(0.1))
                )
            }
            .buttonStyle(.pressableCard)
        }
    }

    // MARK: - Play button (video/voice)

    private var playButton: some View {
        Button {
            Haptics.feedback(style: .light)
            withAnimation(.linear(duration: 0.2)) { playProgress = 0 }
            ticker?.invalidate()
            ticker = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                Task { @MainActor in
                    let dur = max(Double(message.durationSeconds), 1)
                    playProgress += CGFloat(0.05 / dur)
                    if playProgress >= 1 { playProgress = 0; ticker?.invalidate() }
                }
            }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "play.fill")
                Text("Play")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(tint)
            )
        }
        .buttonStyle(.pressableCard)
    }

    // MARK: - Labels

    private var durationLabel: String {
        let m = message.durationSeconds / 60, s = message.durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func timeLabel(progress: CGFloat) -> String {
        let cur = Int(progress * CGFloat(message.durationSeconds))
        return String(format: "%d:%02d", cur / 60, cur % 60)
    }
}
