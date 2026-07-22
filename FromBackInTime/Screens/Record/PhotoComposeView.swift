//
//  PhotoComposeView.swift
//  FromBackInTime
//
//  Photo + note composer. Picks a real image from the library (PhotosPicker,
//  no permission prompt), re-encodes it to JPEG, and uploads it to R2 through
//  the message save flow. A short note goes under it.
//

import SwiftUI
import PhotosUI

struct PhotoComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore

    let recipient: Recipient
    let kind: MessageKind
    let occasion: String
    let deliveryDate: Date?

    @State private var note: String = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showSignIn = false
    @State private var sealed = false

    private var canSave: Bool {
        imageData != nil && !note.trimmingCharacters(in: .whitespaces).isEmpty && !isSaving
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                ComposerTopBar(recipientName: recipient.name, occasion: occasion, fallback: "Photo & note") {
                    dismiss()
                }
                photoArea
                noteEditor
                saveButton
            }
            .padding(AppShellTheme.screenPadding)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .background(AppBackground())
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .savingOverlay(isSaving, message: "Sealing your photo\u{2026}", detail: "Just a moment.")
        .scheduledCover(sealed, recipientName: recipient.name, medium: .photo, kind: kind,
                        deliveryDate: deliveryDate.map(MockAppStore.effectiveDelivery))
        .saveGating(
            showSignIn: $showSignIn,
            error: $saveError,
            signInSubtitle: "Sign in to seal this photo and schedule its delivery.",
            retry: save
        )
    }

    private var photoArea: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.07), radius: 12, y: 5)

                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                } else {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(AppShellTheme.accent)
                        Text("Tap to add a photo")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                        Text("Choose from your library.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppShellTheme.subtitle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xxxl)
                }
            }
            .frame(height: 260)
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    imageData = Self.normalizedJPEG(data)
                }
            }
        }
        .a11y("photo.pick")
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
                    .a11y("photo.note")
                if note.isEmpty {
                    Text("A few words to go with the photo...")
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
            Text(isSaving ? "Saving..." : "Save & schedule")
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
        guard !isSaving else { return }
        guard !authStore.state.isAnonymous else {
            showSignIn = true
            return
        }
        let msg = Message(
            recipientID: recipient.id,
            kind: kind,
            medium: .photo,
            occasion: occasion,
            deliveryDate: deliveryDate,
            durationSeconds: 0,
            bodyText: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        isSaving = true
        Task {
            let ok = await store.saveMessage(msg, mediaData: imageData)
            isSaving = false
            if ok {
                Haptics.notification(type: .success)
                sealed = true
            } else {
                Haptics.notification(type: .error)
                saveError = store.error ?? "Something went wrong. Please try again."
            }
        }
    }

    /// Re-encode to JPEG so the upload content-type (image/jpeg) always matches
    /// the bytes, whatever the source format (HEIC, PNG, ...).
    private static func normalizedJPEG(_ data: Data) -> Data {
        guard let image = UIImage(data: data), let jpeg = image.jpegData(compressionQuality: 0.85) else {
            return data
        }
        return jpeg
    }
}
