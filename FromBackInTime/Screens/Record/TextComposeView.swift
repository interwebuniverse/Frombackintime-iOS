//
//  TextComposeView.swift
//  FromBackInTime
//
//  Written message composer. Big paper-like editor, character/word count,
//  save writes the body into the message.
//

import SwiftUI

struct TextComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore

    let recipient: Recipient
    let kind: MessageKind
    let occasion: String
    let deliveryDate: Date?

    @State private var body_: String = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showSignIn = false
    @FocusState private var focused: Bool

    private var trimmed: String { body_.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSave: Bool { !trimmed.isEmpty }
    private var wordCount: Int {
        trimmed.isEmpty ? 0 : trimmed.split { $0.isWhitespace || $0.isNewline }.count
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            header
            editor
            saveButton
        }
        .padding(AppShellTheme.screenPadding)
        .padding(.bottom, AppSpacing.lg)
        .background(AppBackground())
        .navigationTitle("Written message")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focused = true }
        .saveGating(
            showSignIn: $showSignIn,
            error: $saveError,
            signInSubtitle: "Sign in to seal this message and schedule its delivery.",
            retry: save
        )
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            RecipientAvatar(recipient: recipient, size: 32)
            VStack(alignment: .leading, spacing: 1) {
                Text("To \(recipient.name)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                Text(occasion.isEmpty ? "Message" : occasion)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle)
            }
            Spacer()
            Text("\(wordCount) word\(wordCount == 1 ? "" : "s")")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
        }
    }

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $body_)
                .focused($focused)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .lineSpacing(4)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .a11y("text.field")
            if body_.isEmpty {
                Text("Dear \(recipient.name),\n\nWhen you read this…")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle.opacity(0.45))
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .allowsHitTesting(false)
            }
        }
        .background(.white, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .strokeBorder(AppShellTheme.subtitle.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }

    private var saveButton: some View {
        Button(action: save) {
            Text(isSaving ? "Saving\u{2026}" : "Save & schedule")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(canSave ? AppShellTheme.accent : AppShellTheme.subtitle.opacity(0.4))
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSave || isSaving)
    }

    private func save() {
        guard !isSaving else { return }
        // Scheduling requires a real account; the gate also stops drafts from
        // being created under an anonymous identity that sign-in would orphan.
        guard !authStore.state.isAnonymous else {
            showSignIn = true
            return
        }
        let msg = Message(
            recipientID: recipient.id,
            kind: kind,
            medium: .text,
            occasion: occasion,
            deliveryDate: deliveryDate,
            durationSeconds: 0,
            bodyText: trimmed
        )
        isSaving = true
        Task {
            let ok = await store.saveMessage(msg)
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
