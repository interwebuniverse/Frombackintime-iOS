//
//  AddPersonView.swift
//  FromBackInTime
//
//  Sheet to add or edit a recipient. Writes through MockAppStore so the
//  person shows up across Home, People, Library, and Create. Adding requires
//  a real account (recipients must survive the anonymous-to-signed-in
//  upgrade), so anonymous users get the sign-in gate first.
//

import SwiftUI

struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore

    /// When set, the sheet edits this person instead of creating a new one.
    var editing: Recipient? = nil

    @State private var name: String
    @State private var relationship: String
    @State private var email: String
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showSignIn = false

    init(editing: Recipient? = nil) {
        self.editing = editing
        _name = State(initialValue: editing?.name ?? "")
        _relationship = State(initialValue: editing?.relationship ?? "")
        _email = State(initialValue: editing?.email ?? "")
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && email.contains("@") && email.contains(".")
            && !isSaving
    }

    var body: some View {
        NavigationStack {
            formContent
                .background(AppBackground())
                .scrollContentBackground(.hidden)
        }
    }

    private var formContent: some View {
        Form {
                Section("Who is this?") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .a11y("person.name.field")
                    TextField("Relationship (e.g. Mother, Friend)", text: $relationship)
                        .textInputAutocapitalization(.words)
                    TextField("Email (where the message is delivered)", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
                Section {
                    Text("This person will show up in your People list and as a target you can send messages to.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                AppSheetHeader(title: editing == nil ? "Add person" : "Edit person", trailing: .close { dismiss() })
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Haptics.feedback(style: .medium)
                    save()
                } label: {
                    Text(isSaving ? "Saving\u{2026}" : (editing == nil ? "Add this person" : "Save changes"))
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
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.bottom, AppSpacing.sm)
                .a11y("person.save")
            }
            .saveGating(
                showSignIn: $showSignIn,
                error: $saveError,
                signInSubtitle: "Sign in so the people you add stay tied to your account.",
                retry: save
            )
    }

    private func save() {
        guard !isSaving else { return }
        guard !authStore.state.isAnonymous else {
            showSignIn = true
            return
        }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedRelationship = relationship.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        isSaving = true
        Task {
            let ok: Bool
            if let editing {
                ok = await store.updateRecipient(
                    id: editing.id,
                    name: trimmedName,
                    relationship: trimmedRelationship,
                    email: trimmedEmail
                )
            } else {
                ok = await store.addRecipient(
                    name: trimmedName,
                    relationship: trimmedRelationship,
                    email: trimmedEmail
                )
            }
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
