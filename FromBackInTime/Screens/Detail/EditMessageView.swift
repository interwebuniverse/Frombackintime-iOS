//
//  EditMessageView.swift
//  FromBackInTime
//
//  Edit a scheduled message's who / when / occasion after it was recorded, so a
//  changed plan doesn't mean deleting and re-recording. The media itself never
//  changes here. Presented as a sheet from the message detail.
//

import SwiftUI

struct EditMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store

    let message: Message
    /// Called with the freshly-updated values so the detail view can reflect
    /// them without waiting for a full reload.
    var onSaved: (String, String, Date?) -> Void = { _, _, _ in }

    @State private var recipientID: String
    @State private var occasion: String
    @State private var deliveryDate: Date
    @State private var isSaving = false
    @State private var saveError: String?

    init(message: Message, onSaved: @escaping (String, String, Date?) -> Void = { _, _, _ in }) {
        self.message = message
        self.onSaved = onSaved
        _recipientID = State(initialValue: message.recipientID)
        _occasion = State(initialValue: message.occasion)
        _deliveryDate = State(initialValue: message.deliveryDate ?? Calendar.current.date(byAdding: .month, value: 6, to: .now) ?? .now)
    }

    /// Any future moment works; the buffer keeps "save" from racing a time
    /// that passes while the sheet is open.
    private var earliestDelivery: Date {
        .now.addingTimeInterval(15 * 60)
    }

    private var canSave: Bool {
        !occasion.trimmingCharacters(in: .whitespaces).isEmpty && !recipientID.isEmpty && !isSaving
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    section(title: "To whom?") { recipientPicker }
                    section(title: "Occasion") {
                        TextField("e.g. Birthday, Wedding, Last words", text: $occasion)
                            .textInputAutocapitalization(.sentences)
                            .padding(AppSpacing.md)
                            .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .strokeBorder(AppShellTheme.subtitle.opacity(0.15), lineWidth: 1)
                            )
                    }
                    if message.kind == .standard {
                        section(title: "Delivery date & time") {
                            VStack(spacing: 0) {
                                DatePicker("", selection: $deliveryDate, in: earliestDelivery..., displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .datePickerStyle(.graphical)
                                Text("Your local time. We deliver on the minute.")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppShellTheme.subtitle)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(AppSpacing.md)
                            .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                            .shadow(color: AppShellTheme.cardShadow, radius: 10, y: 4)
                        }
                    }
                    saveButton
                }
                .padding(AppShellTheme.screenPadding)
                .padding(.bottom, AppSpacing.xxxl)
            }
            .background(AppBackground())
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppShellTheme.accent)
                }
            }
            .alert("Couldn't save", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveError ?? "")
            }
            .a11y("edit.screen")
        }
    }

    @ViewBuilder
    private func section<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .textCase(.uppercase)
            content()
        }
    }

    private var recipientPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                ForEach(store.recipients) { r in
                    Button {
                        Haptics.selection()
                        recipientID = r.id
                    } label: {
                        VStack(spacing: AppSpacing.xs) {
                            RecipientAvatar(recipient: r, size: 54)
                            Text(r.name)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppShellTheme.title)
                        }
                        .padding(AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .fill(recipientID == r.id ? AppShellTheme.accent.opacity(0.15) : .clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .strokeBorder(recipientID == r.id ? AppShellTheme.accent : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Text(isSaving ? "Saving\u{2026}" : "Save changes")
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
        .a11y("edit.save")
    }

    private func save() {
        guard canSave else { return }
        let trimmed = occasion.trimmingCharacters(in: .whitespacesAndNewlines)
        let date: Date? = message.kind == .standard ? deliveryDate : message.deliveryDate
        isSaving = true
        Task {
            let ok = await store.updateMessage(
                id: message.id,
                occasion: trimmed,
                recipientId: recipientID,
                deliveryDate: date
            )
            isSaving = false
            if ok {
                Haptics.notification(type: .success)
                onSaved(trimmed, recipientID, date)
                dismiss()
            } else {
                Haptics.notification(type: .error)
                saveError = store.error ?? "Something went wrong. Please try again."
            }
        }
    }
}
