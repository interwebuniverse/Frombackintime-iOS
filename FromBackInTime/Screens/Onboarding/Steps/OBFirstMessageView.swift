//
//  OBFirstMessageView.swift
//  FromBackInTime
//
//  The one-screen first message, opened from the end of onboarding. Everything
//  that can be prefilled is prefilled (occasion, arrival, relationship); the
//  user types a name and an email, records a short selfie video, and taps one
//  button. Sealing (or skipping) hands control back to OBFirstActionView,
//  which puts up the gated paywall and finishes onboarding once it unlocks.
//

import AVKit
import SwiftUI
import UIKit

struct OBFirstMessageView: View {
    @Environment(\.dismiss) private var dismiss

    /// Called with the recorded payload on seal, or nil on skip. The caller
    /// gates with the paywall and completes onboarding.
    let onFinish: (AppState.FirstMessagePayload?) -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var occasion = "A hello from the past"
    @State private var preset: DeliveryPreset = .year
    @State private var showCamera = false
    @State private var videoData: Data?
    @State private var videoContentType = "video/mp4"
    @State private var videoDuration = 1
    @State private var previewPlayer: AVPlayer?
    @State private var deniedPermission: MediaPermission.Kind?

    private var emailValid: Bool { email.contains("@") && email.contains(".") }
    private var canSeal: Bool {
        videoData != nil && !name.trimmingCharacters(in: .whitespaces).isEmpty && emailValid
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header

                    recordCard

                    step(title: "Who gets it?") {
                        VStack(spacing: AppSpacing.sm) {
                            field("Their name", text: $name, keyboard: .default)
                                .textInputAutocapitalization(.words)
                                .a11y("first.name")
                            field("Their email (where it arrives)", text: $email, keyboard: .emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .a11y("first.email")
                        }
                    }

                    step(title: "When does it arrive?") {
                        HStack(spacing: AppSpacing.sm) {
                            chip(.tomorrow)
                            chip(.month)
                            chip(.year)
                        }
                        Text("Arrives \(preset == .tomorrow ? "tomorrow" : preset.label.lowercased()): \(DateFormatter.prettyDateTime.string(from: preset.date)), their local inbox.")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppShellTheme.accent)
                    }

                    sealButton

                    Button("Skip for now") {
                        Haptics.selection()
                        onFinish(nil)
                    }
                    .textButton()
                    .frame(maxWidth: .infinity)
                    .a11y("first.skip")
                }
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .fullScreenCover(isPresented: $showCamera) {
            MoviePicker { data, duration, contentType, url in
                if let data {
                    videoData = data
                    videoContentType = contentType
                    videoDuration = duration
                    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    previewPlayer = url.map { AVPlayer(url: $0) }
                }
            }
            .ignoresSafeArea()
        }
        .permissionAlert($deniedPermission)
        .a11y("first.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Spacer()
                Button {
                    Haptics.selection()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppShellTheme.title)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial, in: Circle())
                        .background(Circle().fill(.white.opacity(0.55)))
                        .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .a11y("first.close")
            }
            Text("Your first message")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
            Text("Thirty seconds is enough. Just say what you'd want them to hear.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, AppSpacing.lg)
    }

    // MARK: - Record card

    private var recordCard: some View {
        Group {
            if let previewPlayer {
                VStack(spacing: AppSpacing.md) {
                    VideoPlayer(player: previewPlayer)
                        .aspectRatio(9 / 16, contentMode: .fit)
                        .frame(maxHeight: 340)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                    Button {
                        Haptics.selection()
                        self.previewPlayer?.pause()
                        self.previewPlayer = nil
                        videoData = nil
                        startRecording()
                    } label: {
                        Text("Retake")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppShellTheme.accent)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button(action: startRecording) {
                    VStack(spacing: AppSpacing.sm) {
                        ZStack {
                            Circle()
                                .strokeBorder(Color.red.opacity(0.5), lineWidth: 3)
                                .frame(width: 74, height: 74)
                            Circle().fill(.red).frame(width: 58, height: 58)
                        }
                        Text("Tap to record")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                        Text("Selfie camera, up to five minutes.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(AppShellTheme.subtitle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xxl)
                    .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
                            .strokeBorder(AppShellTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: AppShellTheme.cardShadow, radius: 14, y: 6)
                }
                .buttonStyle(.plain)
                .a11y("first.record")
            }
        }
    }

    private func startRecording() {
        Haptics.feedback(style: .medium)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCamera = true
            return
        }
        Task {
            guard await MediaPermission.ensure(.camera) else {
                deniedPermission = .camera
                return
            }
            guard await MediaPermission.ensure(.microphone) else {
                deniedPermission = .microphone
                return
            }
            showCamera = true
        }
    }

    // MARK: - Pieces

    @ViewBuilder
    private func step<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
            content()
        }
    }

    private func field(_ prompt: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        TextField(prompt, text: text)
            .keyboardType(keyboard)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .padding(AppSpacing.md)
            .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .strokeBorder(AppShellTheme.subtitle.opacity(0.15), lineWidth: 1)
            )
    }

    private func chip(_ value: DeliveryPreset) -> some View {
        Button {
            Haptics.selection()
            preset = value
        } label: {
            Text(value.label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(preset == value ? .white : AppShellTheme.title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(preset == value ? AppShellTheme.accent : .white.opacity(0.75))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .strokeBorder(preset == value ? .clear : AppShellTheme.subtitle.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var sealButton: some View {
        Button {
            guard let videoData else { return }
            Haptics.feedback(style: .medium)
            previewPlayer?.pause()
            onFinish(AppState.FirstMessagePayload(
                recipientName: name.trimmingCharacters(in: .whitespaces),
                recipientEmail: email.trimmingCharacters(in: .whitespaces),
                occasion: occasion.trimmingCharacters(in: .whitespaces),
                deliveryDate: preset.date,
                videoData: videoData,
                contentType: videoContentType,
                durationSeconds: max(videoDuration, 1)
            ))
        } label: {
            Text("Seal & send to the future")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(canSeal ? AppShellTheme.accent : AppShellTheme.subtitle.opacity(0.4))
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSeal)
        .a11y("first.seal")
    }
}
