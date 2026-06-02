//
//  VoiceRecordView.swift
//  FromBackInTime
//
//  Voice-note composer. Same lifecycle as RecordView (idle -> recording ->
//  recorded -> save -> dismiss the sheet). A live, audio-reactive-feeling
//  waveform replaces the camera preview so it reads as voice, not video.
//

import SwiftUI

struct VoiceRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store

    let recipient: Recipient
    let kind: MessageKind
    let occasion: String
    let deliveryDate: Date?

    @State private var state: RecState = .idle
    @State private var elapsed: Int = 0
    @State private var phase: CGFloat = 0
    @State private var ticker: Timer?

    enum RecState { case idle, recording, recorded }

    private var tint: Color { Color(hue: MessageMedium.voice.hue, saturation: 0.55, brightness: 0.9) }

    var body: some View {
        ZStack {
            backdrop

            VStack {
                topBar
                Spacer()
                centerContent
                Spacer()
                bottomBar
            }
            .padding(AppShellTheme.screenPadding)
            .padding(.bottom, AppSpacing.lg)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onDisappear { ticker?.invalidate() }
    }

    // MARK: - Backdrop

    private var backdrop: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 36/255, green: 24/255, blue: 56/255),
                         Color(red: 18/255, green: 12/255, blue: 36/255)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [tint.opacity(0.35), .clear],
                center: .center, startRadius: 0, endRadius: 300
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Top bar

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
                Text(occasion.isEmpty ? "Voice note" : occasion)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }

    // MARK: - Center

    private var centerContent: some View {
        VStack(spacing: AppSpacing.xl) {
            waveform
                .frame(height: 120)

            Text(timerLabel)
                .font(.system(size: 48, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
            Text(stateLabel)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var waveform: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: state != .recording)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let bars = 36
                let barWidth = size.width / CGFloat(bars * 2)
                let midY = size.height / 2
                for i in 0..<bars {
                    let phaseOffset = Double(i) * 0.32
                    let baseAmp: CGFloat
                    switch state {
                    case .idle:      baseAmp = 4
                    case .recording: baseAmp = CGFloat(20 + 28 * abs(sin(t * 4 + phaseOffset)) + 18 * abs(sin(t * 9 + phaseOffset * 1.7)))
                    case .recorded:  baseAmp = CGFloat(8 + 8 * abs(sin(phaseOffset * 2)))
                    }
                    let x = (CGFloat(i) + 0.5) * (size.width / CGFloat(bars))
                    let rect = CGRect(
                        x: x - barWidth / 2,
                        y: midY - baseAmp,
                        width: barWidth,
                        height: baseAmp * 2
                    )
                    let path = Path(roundedRect: rect, cornerRadius: barWidth)
                    ctx.fill(path, with: .color(tint.opacity(state == .idle ? 0.35 : 0.95)))
                }
            }
        }
    }

    private var timerLabel: String {
        let m = elapsed / 60, s = elapsed % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var stateLabel: String {
        switch state {
        case .idle: return "Tap to record · just your voice"
        case .recording: return "Recording…"
        case .recorded: return "Sounds good?"
        }
    }

    // MARK: - Bottom controls

    private var bottomBar: some View {
        Group {
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

                    Button(action: save) {
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
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 4)
                            .frame(width: 84, height: 84)
                        if state == .recording {
                            RoundedRectangle(cornerRadius: 6).fill(tint).frame(width: 28, height: 28)
                        } else {
                            Circle().fill(tint).frame(width: 64, height: 64)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggleRecording() {
        switch state {
        case .idle:
            Haptics.feedback(style: .medium)
            state = .recording
            elapsed = 0
            ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                Task { @MainActor in elapsed += 1 }
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
        Haptics.notification(type: .success)
        let msg = Message(
            recipientID: recipient.id,
            kind: kind,
            medium: .voice,
            occasion: occasion,
            deliveryDate: deliveryDate,
            durationSeconds: max(elapsed, 1)
        )
        store.saveMessage(msg)
        dismiss()
    }
}
