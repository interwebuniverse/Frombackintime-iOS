//
//  PhotoComposeView.swift
//  FromBackInTime
//
//  Photo + note composer. Lets the user mock-pick a photo (we paint a soft
//  placeholder with the recipient's tint) and type a short note under it.
//

import SwiftUI

struct PhotoComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store

    let recipient: Recipient
    let kind: MessageKind
    let occasion: String
    let deliveryDate: Date?

    @State private var note: String = ""
    @State private var hasPhoto: Bool = false

    private var canSave: Bool {
        hasPhoto && !note.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                photoArea
                noteEditor
                saveButton
            }
            .padding(AppShellTheme.screenPadding)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .background(AppBackground())
        .scrollContentBackground(.hidden)
        .navigationTitle("Photo & note")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var photoArea: some View {
        Button {
            Haptics.feedback(style: .light)
            withAnimation(.spring(duration: 0.3)) { hasPhoto = true }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.07), radius: 12, y: 5)

                if hasPhoto {
                    photoMock
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                } else {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(AppShellTheme.accent)
                        Text("Tap to add a photo")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                        Text("Choose from your library or take a new one.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppShellTheme.subtitle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xxxl)
                }
            }
            .frame(height: 260)
        }
        .buttonStyle(.plain)
    }

    /// Stand-in image until a real picker is wired. Uses the recipient's
    /// avatar tint so the result feels personalised.
    private var photoMock: some View {
        ZStack {
            LinearGradient(
                colors: [recipient.avatarColor, recipient.avatarColor.opacity(0.55)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Image(systemName: "sun.max.fill")
                .font(.system(size: 80, weight: .regular))
                .foregroundStyle(.white.opacity(0.55))
                .offset(x: 70, y: -50)
            VStack(alignment: .leading) {
                Spacer()
                Text("A moment for \(recipient.name)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(AppSpacing.md)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var noteEditor: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Your note")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .textCase(.uppercase)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $note)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                if note.isEmpty {
                    Text("A few words to go with the photo…")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .background(.white, in: RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .strokeBorder(AppShellTheme.subtitle.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Text("Save & schedule")
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
        .disabled(!canSave)
    }

    private func save() {
        Haptics.notification(type: .success)
        let msg = Message(
            recipientID: recipient.id,
            kind: kind,
            medium: .photo,
            occasion: occasion,
            deliveryDate: deliveryDate,
            durationSeconds: 0,
            bodyText: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.saveMessage(msg)
        dismiss()
    }
}
