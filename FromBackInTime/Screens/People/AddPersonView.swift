//
//  AddPersonView.swift
//  FromBackInTime
//
//  Sheet to add a new recipient. Writes straight into MockAppStore so the
//  new person shows up across Home, People, Library, and Create.
//

import SwiftUI

struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MockAppStore.self) private var store

    @State private var name: String = ""
    @State private var relationship: String = ""

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
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
                    TextField("Relationship (e.g. Mother, Friend)", text: $relationship)
                        .textInputAutocapitalization(.words)
                }
                Section {
                    Text("This person will show up in your People list and as a target you can send messages to.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                }
            }
            .navigationTitle("Add person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppShellTheme.subtitle)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        Haptics.feedback(style: .medium)
                        store.addRecipient(
                            name: name.trimmingCharacters(in: .whitespaces),
                            relationship: relationship.trimmingCharacters(in: .whitespaces)
                        )
                        dismiss()
                    }
                    .disabled(!canSave)
                    .foregroundStyle(canSave ? AppShellTheme.accent : AppShellTheme.subtitle.opacity(0.4))
                }
            }
    }
}
