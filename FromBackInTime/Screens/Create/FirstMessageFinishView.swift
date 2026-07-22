//
//  FirstMessageFinishView.swift
//  FromBackInTime
//
//  Saves the first message that was recorded during onboarding, right after
//  the paywall unlocks: sign-in gate if the session is still anonymous, then
//  recipient create + upload + finalize, ending on the same sealed
//  confirmation the composers use. Presented as a sheet by RootView.
//

import SwiftUI

struct FirstMessageFinishView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore

    enum Phase: Equatable {
        case gate, saving, done
        case failed(String)
    }
    @State private var phase: Phase = .gate
    @State private var showSignIn = false
    @State private var started = false

    private var payload: AppState.FirstMessagePayload? { appState.pendingFirstMessage }

    var body: some View {
        ZStack {
            AppBackground()

            switch phase {
            case .gate:
                gateContent
            case .saving:
                savingContent
            case .done:
                MessageScheduledView(
                    recipientName: payload?.recipientName ?? "them",
                    medium: .video,
                    kind: .standard,
                    deliveryDate: payload?.deliveryDate
                )
            case .failed(let message):
                failedContent(message)
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            guard !started else { return }
            started = true
            if authStore.state.isAnonymous {
                phase = .gate
                showSignIn = true
            } else {
                startSave()
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInSheet(
                subtitle: "Sign in so your first message outlives this phone and delivers no matter what.",
                onSignedIn: { startSave() }
            )
        }
        // The confirmation's Done button ends the flow.
        .onReceive(NotificationCenter.default.publisher(for: .createFlowFinished)) { _ in
            appState.pendingFirstMessage = nil
            dismiss()
        }
        .a11y("firstfinish.screen")
    }

    // MARK: - States

    private var gateContent: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Image("ob-d-shield")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
            Text("Your first message is ready")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .multilineTextAlignment(.center)
            Text("Sign in to seal it, so it delivers even if this phone is gone.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .multilineTextAlignment(.center)
            Button("Sign in") {
                Haptics.selection()
                showSignIn = true
            }
            .primaryButton()
            .padding(.top, AppSpacing.sm)
            Button("Discard it") {
                Haptics.selection()
                appState.pendingFirstMessage = nil
                dismiss()
            }
            .textButton()
            Spacer()
        }
        .padding(.horizontal, AppSpacing.xxl)
    }

    private var savingContent: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(AppShellTheme.accent)
            Text("Sealing your first message\u{2026}")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
            Text("Uploading the video. Hang tight.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
        }
    }

    private func failedContent(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Text("Couldn't seal it")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
            Text(message)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button("Try again") {
                Haptics.selection()
                startSave()
            }
            .primaryButton()
            .padding(.top, AppSpacing.sm)
            Button("Discard it") {
                Haptics.selection()
                appState.pendingFirstMessage = nil
                dismiss()
            }
            .textButton()
            Spacer()
        }
        .padding(.horizontal, AppSpacing.xxl)
    }

    // MARK: - Save

    private func startSave() {
        guard let payload else {
            dismiss()
            return
        }
        phase = .saving
        Task {
            // Reuse a person with the same email if one exists (retry safety),
            // otherwise create them.
            var recipient = store.recipients.first {
                $0.email.caseInsensitiveCompare(payload.recipientEmail) == .orderedSame
            }
            if recipient == nil {
                let ok = await store.addRecipient(
                    name: payload.recipientName,
                    relationship: "Someone I love",
                    email: payload.recipientEmail
                )
                guard ok else {
                    phase = .failed(store.error ?? "We couldn't save who it's for. Please try again.")
                    return
                }
                recipient = store.recipients.first {
                    $0.email.caseInsensitiveCompare(payload.recipientEmail) == .orderedSame
                }
            }
            guard let recipient else {
                phase = .failed("We couldn't save who it's for. Please try again.")
                return
            }

            let msg = Message(
                recipientID: recipient.id,
                kind: .standard,
                medium: .video,
                occasion: payload.occasion.isEmpty ? "A hello from the past" : payload.occasion,
                deliveryDate: payload.deliveryDate,
                durationSeconds: payload.durationSeconds
            )
            let ok = await store.saveMessage(msg, mediaData: payload.videoData, mediaContentType: payload.contentType)
            if ok {
                Haptics.notification(type: .success)
                phase = .done
            } else {
                Haptics.notification(type: .error)
                phase = .failed(store.error ?? "Something went wrong while sealing. Please try again.")
            }
        }
    }
}
