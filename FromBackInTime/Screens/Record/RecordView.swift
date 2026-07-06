//
//  RecordView.swift
//  FromBackInTime
//
//  Screen 8 (Record). Mock selfie-camera. Tapping the record button starts
//  a fake timer; tapping again stops. "Save" writes the message into the
//  store and dismisses the entire create sheet, so the new entry shows up
//  in Home, Library, and the recipient's icon page immediately.
//

import SwiftUI

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store

    let recipient: Recipient
    let kind: MessageKind
    let occasion: String
    let deliveryDate: Date?

    @State private var state: RecState = .idle
    @State private var elapsed: Int = 0
    @State private var ticker: Timer?
    @State private var showCamera = false
    @State private var videoData: Data?

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
        .fullScreenCover(isPresented: $showCamera) {
            MoviePicker { data, duration in
                if let data {
                    videoData = data
                    elapsed = duration
                    state = .recorded
                }
            }
            .ignoresSafeArea()
        }
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
                        Text("Save")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(Capsule().fill(.white))
                    }
                    .buttonStyle(.plain)
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
            showCamera = true
        case .recording:
            Haptics.feedback(style: .light)
            state = .recorded
            ticker?.invalidate()
        case .recorded:
            break
        }
    }

    private func save() {
        Haptics.notification(type: .success)
        let msg = Message(
            recipientID: recipient.id,
            kind: kind,
            medium: .video,
            occasion: occasion,
            deliveryDate: deliveryDate,
            durationSeconds: max(elapsed, 1)
        )
        let data = videoData
        Task {
            await store.saveMessage(msg, mediaData: data)
            dismiss()
        }
    }
}
