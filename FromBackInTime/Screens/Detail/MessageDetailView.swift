//
//  MessageDetailView.swift
//  FromBackInTime
//
//  Detail view for a single message. Zoom-transition destination from any
//  message row. Fetches the full record on open (list rows carry metadata
//  only), then plays the real media: AVPlayer for video/voice via the
//  backend's short-lived playback URL, AsyncImage for photos, decrypted body
//  for written messages.
//

import AVKit
import SwiftUI

struct MessageDetailView: View {
    @Environment(MockAppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let message: Message

    @State private var detail: Message?
    @State private var mediaURL: URL?
    @State private var isLoadingDetail = true
    @State private var actionError: String?
    @State private var isWorking = false
    @State private var showEdit = false

    // Voice playback
    @State private var player: AVPlayer?
    @State private var timeObserver: Any?
    @State private var isPlaying = false
    @State private var playProgress: CGFloat = 0
    // Cached so the body re-evaluating doesn't spin up a new player each time.
    @State private var videoPlayer: AVPlayer?

    /// Freshest copy: the fetched detail when it lands, the list row until then.
    private var current: Message { detail ?? message }

    private var recipient: Recipient? { store.recipient(id: current.recipientID) }
    private var tint: Color { Color(hue: current.medium.hue, saturation: 0.62, brightness: 0.7) }

    var body: some View {
        AppNavScrollView(
            title: current.occasion,
            leading: .back { dismiss() }
        ) {
            VStack(spacing: AppSpacing.xl) {
                hero
                metadata
                actions
            }
            .padding(.horizontal, AppShellTheme.screenPadding)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .task { await loadDetail() }
        .onDisappear { stopPlayback() }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { note in
            handleInterruption(note)
        }
        .sheet(isPresented: $showEdit) {
            EditMessageView(message: current) { occasion, recipientID, date in
                var updated = detail ?? message
                updated.occasion = occasion
                updated.recipientID = recipientID
                updated.deliveryDate = date
                detail = updated
            }
            .presentationCornerRadius(28)
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { actionError != nil },
            set: { if !$0 { actionError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(actionError ?? "")
        }
        .a11y("detail.screen")
    }

    private func loadDetail() async {
        configureAudioSession()
        guard let result = await store.messageDetail(id: message.id) else {
            isLoadingDetail = false
            return
        }
        detail = result.message
        mediaURL = result.mediaURL
        if message.medium == .video, let url = result.mediaURL {
            videoPlayer = AVPlayer(url: url)
        }
        isLoadingDetail = false
    }

    /// Route audio through the media channel so voice notes and videos are
    /// audible even with the ring/silent switch flipped to silent.
    private func configureAudioSession() {
        guard message.medium == .video || message.medium == .voice else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Hero

    @ViewBuilder
    private var hero: some View {
        switch current.medium {
        case .video: videoHero
        case .voice: voiceHero
        case .photo: photoHero
        case .text:  textHero
        }
    }

    @ViewBuilder
    private var videoHero: some View {
        Group {
            if let videoPlayer {
                VideoPlayer(player: videoPlayer)
            } else {
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 18/255, green: 22/255, blue: 36/255), tint],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    if let recipient {
                        Text(recipient.initials)
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(.white.opacity(0.18))
                    }
                    if isLoadingDetail {
                        ProgressView().tint(.white)
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text(isLoadingDetail ? durationLabel : "Video not uploaded yet · \(durationLabel)")
                                .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.black.opacity(0.45)))
                        .padding(AppSpacing.md)
                    }
                }
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
                    colors: [tint.opacity(0.85), Color(hue: current.medium.hue, saturation: 0.4, brightness: 0.95)],
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
        TimelineView(.animation(minimumInterval: 1.0/30.0, paused: !isPlaying)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let bars = 28
                let midY = size.height / 2
                for i in 0..<bars {
                    let phase = Double(i) * 0.34
                    let amp = isPlaying
                        ? 8 + 22 * abs(sin(t * 2 + phase)) + 12 * abs(sin(t * 5 + phase * 1.5))
                        : 10 + 14 * abs(sin(phase * 2.2))
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
                }
                if let mediaURL {
                    AsyncImage(url: mediaURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.system(size: 64, weight: .regular))
                                .foregroundStyle(.white.opacity(0.6))
                        default:
                            ProgressView().tint(.white)
                        }
                    }
                } else if isLoadingDetail {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 88, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                        .offset(x: 70, y: -50)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            if !current.bodyText.isEmpty {
                Text(current.bodyText)
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
            if current.bodyText.isEmpty, isLoadingDetail {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text(current.bodyText.isEmpty ? "This message has no written words." : current.bodyText)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .lineSpacing(4)
                    .foregroundStyle(AppShellTheme.title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                infoChip(icon: current.medium.glyph, label: current.medium.shortLabel, tint: tint)
                if current.kind == .ctm {
                    infoChip(icon: "app-ic-shield",
                             label: current.ctmActivated ? "CTM armed" : "CTM standby",
                             tint: AppShellTheme.gold)
                }
                if let d = current.deliveryDate {
                    infoChip(icon: "app-ic-calendar",
                             label: DateFormatter.prettyDateTime.string(from: d),
                             tint: AppShellTheme.accent)
                }
            }
        }
    }

    private func infoChip(icon: String, label: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            AppIcon(name: icon, size: 12, color: tint)
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(tint.opacity(0.14)))
    }

    private var canEdit: Bool {
        current.kind == .standard || !current.ctmActivated
    }

    private var actions: some View {
        VStack(spacing: AppSpacing.md) {
            if canEdit {
                Button {
                    Haptics.selection()
                    showEdit = true
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        AppIcon(name: "app-ic-edit", size: 16, color: AppShellTheme.accent)
                        Text("Edit details")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(AppShellTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .fill(AppShellTheme.accent.opacity(0.1))
                    )
                }
                .buttonStyle(.pressableCard)
                .disabled(isWorking)
                .a11y("detail.edit")
            }

            if current.kind == .ctm {
                if current.ctmActivated {
                    // The backend has no un-arm; deleting the message is the
                    // only way to cancel, so say exactly that.
                    Text("This switch is armed. Delete the message to cancel it.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                } else {
                    Button {
                        Haptics.feedback(style: .medium)
                        activateCTM()
                    } label: {
                        Text(isWorking ? "Arming\u{2026}" : "Activate CTM")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(AppShellTheme.gold)
                            )
                    }
                    .buttonStyle(.pressableCard)
                    .disabled(isWorking)
                }
            }

            Button(role: .destructive) {
                Haptics.notification(type: .warning)
                deleteMessage()
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    AppIcon(name: "app-ic-trash", size: 16, color: .red)
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
            .disabled(isWorking)
            .a11y("detail.delete")
        }
        .alert("Share this access code", isPresented: accessCodeBinding) {
            Button("Done", role: .cancel) { store.lastAccessCode = nil }
        } message: {
            Text("Give this one-time code to \(recipient?.name ?? "your recipient"): \(store.lastAccessCode ?? ""). It unlocks the message when it arrives and is shown only once.")
        }
    }

    private func activateCTM() {
        guard !isWorking else { return }
        isWorking = true
        Task {
            let ok = await store.toggleCTMActivation(id: current.id)
            isWorking = false
            if ok {
                Haptics.notification(type: .success)
                detail?.ctmActivated = true
            } else {
                Haptics.notification(type: .error)
                actionError = store.error ?? "Something went wrong. Please try again."
            }
        }
    }

    private func deleteMessage() {
        guard !isWorking else { return }
        isWorking = true
        Task {
            let ok = await store.deleteMessage(id: current.id)
            isWorking = false
            if ok {
                dismiss()
            } else {
                Haptics.notification(type: .error)
                actionError = store.error ?? "Something went wrong. Please try again."
            }
        }
    }

    private var accessCodeBinding: Binding<Bool> {
        Binding(
            get: { store.lastAccessCode != nil },
            set: { if !$0 { store.lastAccessCode = nil } }
        )
    }

    // MARK: - Voice playback (real audio via the presigned URL)

    private var playButton: some View {
        Button {
            Haptics.feedback(style: .light)
            togglePlayback()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                Text(isPlaying ? "Pause" : "Play")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(mediaURL == nil ? AppShellTheme.subtitle.opacity(0.5) : tint)
            )
        }
        .buttonStyle(.pressableCard)
        .disabled(mediaURL == nil)
        .a11y("detail.play")
    }

    private func togglePlayback() {
        guard let mediaURL else { return }
        if isPlaying {
            player?.pause()
            isPlaying = false
            return
        }
        if player == nil {
            let p = AVPlayer(url: mediaURL)
            timeObserver = p.addPeriodicTimeObserver(
                forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
                queue: .main
            ) { time in
                let duration = max(Double(current.durationSeconds), 1)
                let progress = CGFloat(time.seconds / duration)
                Task { @MainActor in
                    playProgress = min(progress, 1)
                    if progress >= 1 {
                        isPlaying = false
                        player?.seek(to: .zero)
                        playProgress = 0
                    }
                }
            }
            player = p
        }
        player?.play()
        isPlaying = true
    }

    // A call/Siri grabbing the audio route pauses AVPlayer under us; reflect
    // that in our own state so the play button and waveform don't read as
    // "playing" over silence.
    private func handleInterruption(_ note: Notification) {
        guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              AVAudioSession.InterruptionType(rawValue: raw) == .began else { return }
        player?.pause()
        videoPlayer?.pause()
        isPlaying = false
    }

    private func stopPlayback() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
        }
        player?.pause()
        player = nil
        timeObserver = nil
        videoPlayer?.pause()
        isPlaying = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    // MARK: - Labels

    private var durationLabel: String {
        let m = current.durationSeconds / 60, s = current.durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func timeLabel(progress: CGFloat) -> String {
        let cur = Int(progress * CGFloat(current.durationSeconds))
        return String(format: "%d:%02d", cur / 60, cur % 60)
    }
}
