//
//  RecordView.swift
//  FromBackInTime
//
//  Screen 8 (Record). Real selfie camera via MoviePicker (falls back to the
//  photo library on the simulator). Tapping record checks camera + microphone
//  permission, then presents the camera; the returned clip's bytes and duration
//  flow into "Save", which uploads to R2 and finalizes the message so it shows
//  up in Home, Library, and the recipient's icon page immediately.
//

import SwiftUI
import UIKit

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore

    let recipient: Recipient
    let kind: MessageKind
    let occasion: String
    let deliveryDate: Date?

    @State private var state: RecState = .idle
    @State private var elapsed: Int = 0
    @State private var ticker: Timer?
    @State private var showCamera = false
    @State private var videoData: Data?
    @State private var videoContentType = "video/mp4"
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showSignIn = false
    @State private var deniedPermission: MediaPermission.Kind?

    enum RecState { case idle, recording, recorded }

    var body: some View {
        ZStack {
            background

            VStack {
                topBar
                Spacer()
                centerControl
                Spacer()
                bottomBar
            }
            .padding(AppShellTheme.screenPadding)
            .padding(.bottom, AppSpacing.lg)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onDisappear { ticker?.invalidate() }
        .savingOverlay(isSaving, message: "Sealing your video\u{2026}")
        .fullScreenCover(isPresented: $showCamera) {
            MoviePicker { data, duration, contentType in
                if let data {
                    videoData = data
                    videoContentType = contentType
                    elapsed = duration
                    state = .recorded
                }
            }
            .ignoresSafeArea()
        }
        .permissionAlert($deniedPermission)
        .saveGating(
            showSignIn: $showSignIn,
            error: $saveError,
            signInSubtitle: "Sign in to seal this video and schedule its delivery.",
            retry: save
        )
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 18/255, green: 22/255, blue: 36/255),
                         Color(red: 32/255, green: 38/255, blue: 60/255)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Mock camera "preview": large soft circle of the recipient avatar tint.
            RadialGradient(
                colors: [recipient.avatarColor.opacity(0.45), .clear],
                center: .center, startRadius: 0, endRadius: 280
            )
            .ignoresSafeArea()

            Image(systemName: "person.crop.circle")
                .font(.system(size: 220, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.08))
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                ticker?.invalidate()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Circle().fill(.white.opacity(0.15)))
            }
            Spacer()
            VStack(spacing: 2) {
                Text(recipient.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(occasion.isEmpty ? "Message" : occasion)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }
            Spacer()
            // Symmetry filler
            Color.clear.frame(width: 44, height: 44)
        }
    }

    private var centerControl: some View {
        VStack(spacing: AppSpacing.lg) {
            Text(timerLabel)
                .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
            Text(stateLabel)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var bottomBar: some View {
        VStack(spacing: AppSpacing.lg) {
            if state == .recorded {
                HStack(spacing: AppSpacing.lg) {
                    Button {
                        Haptics.selection()
                        state = .idle
                        elapsed = 0
                    } label: {
                        Text("Retake")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(Capsule().fill(.white.opacity(0.18)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        save()
                    } label: {
                        Text(isSaving ? "Saving\u{2026}" : "Save")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(Capsule().fill(.white))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                }
            } else {
                Button {
                    toggleRecording()
                } label: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 4)
                            .frame(width: 84, height: 84)
                        if state == .recording {
                            RoundedRectangle(cornerRadius: 6).fill(.red).frame(width: 28, height: 28)
                        } else {
                            Circle().fill(.red).frame(width: 64, height: 64)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var timerLabel: String {
        let m = elapsed / 60
        let s = elapsed % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var stateLabel: String {
        switch state {
        case .idle: return "Tap to record · selfie camera"
        case .recording: return "Recording…"
        case .recorded: return "Looks good?"
        }
    }

    private func toggleRecording() {
        switch state {
        case .idle:
            Haptics.feedback(style: .medium)
            // No camera on the simulator: MoviePicker falls back to the library,
            // which needs no camera/mic grant. On device, a video needs both.
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
        case .recording:
            Haptics.feedback(style: .light)
            state = .recorded
            ticker?.invalidate()
        case .recorded:
            break
        }
    }

    private func save() {
        guard !isSaving else { return }
        guard !authStore.state.isAnonymous else {
            showSignIn = true
            return
        }
        let msg = Message(
            recipientID: recipient.id,
            kind: kind,
            medium: .video,
            occasion: occasion,
            deliveryDate: deliveryDate,
            durationSeconds: max(elapsed, 1)
        )
        guard let data = videoData else {
            Haptics.notification(type: .error)
            saveError = "That recording didn't capture any video. Please record again."
            state = .idle
            elapsed = 0
            return
        }
        isSaving = true
        Task {
            let ok = await store.saveMessage(msg, mediaData: data, mediaContentType: videoContentType)
            isSaving = false
            if ok {
                Haptics.notification(type: .success)
                dismiss()
            } else {
                Haptics.notification(type: .error)
                saveError = store.error ?? "Something went wrong. Please try again."
            }
        }
    }
}
