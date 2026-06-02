//
//  CreateFormView.swift
//  FromBackInTime
//
//  The "to whom · delivery date · occasion" form from the wireframe. Two
//  shapes: standard (date required) and CTM (date hidden, releases when the
//  switch trips). "Save & record" pushes to RecordView.
//

import SwiftUI

struct CreateFormView: View {
    @Environment(MockAppStore.self) private var store

    let kind: MessageKind
    let medium: MessageMedium
    let prefilledRecipient: Recipient?

    @State private var selectedRecipientID: UUID?
    @State private var occasion: String = ""
    @State private var deliveryDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: .now) ?? .now
    @State private var goToComposer: Bool = false

    init(kind: MessageKind, medium: MessageMedium, prefilledRecipient: Recipient? = nil) {
        self.kind = kind
        self.medium = medium
        self.prefilledRecipient = prefilledRecipient
        self._selectedRecipientID = State(initialValue: prefilledRecipient?.id)
    }

    private var canContinue: Bool {
        selectedRecipientID != nil && !occasion.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        bodyContent
            .background(AppBackground())
            .scrollContentBackground(.hidden)
    }

    private var bodyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                kindHeader

                section(title: "To whom?") {
                    recipientPicker
                }

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

                if kind == .standard {
                    section(title: "Date of delivery") {
                        DatePicker("", selection: $deliveryDate, in: Date()..., displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .padding(AppSpacing.md)
                            .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                            .shadow(color: AppShellTheme.cardShadow, radius: 10, y: 4)
                    }
                } else {
                    ctmExplainer
                }

                continueButton
            }
            .padding(AppShellTheme.screenPadding)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .navigationDestination(isPresented: $goToComposer) {
            if let id = selectedRecipientID, let recipient = store.recipient(id: id) {
                composer(for: recipient)
            }
        }
    }

    @ViewBuilder
    private func composer(for recipient: Recipient) -> some View {
        let date = kind == .standard ? deliveryDate : nil
        switch medium {
        case .video:
            RecordView(recipient: recipient, kind: kind, occasion: occasion, deliveryDate: date)
        case .voice:
            VoiceRecordView(recipient: recipient, kind: kind, occasion: occasion, deliveryDate: date)
        case .photo:
            PhotoComposeView(recipient: recipient, kind: kind, occasion: occasion, deliveryDate: date)
        case .text:
            TextComposeView(recipient: recipient, kind: kind, occasion: occasion, deliveryDate: date)
        }
    }

    private var kindHeader: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: kind == .ctm ? "shield.lefthalf.filled" : "paperplane.fill")
                .foregroundStyle(kind == .ctm ? AppShellTheme.gold : AppShellTheme.accent)
            Text(kind == .ctm ? "Critical Timed Message" : "Timed message")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
            Text("·")
                .foregroundStyle(AppShellTheme.subtitle.opacity(0.6))
            Image(systemName: medium.icon)
                .foregroundStyle(Color(hue: medium.hue, saturation: 0.7, brightness: 0.6))
            Text(medium.shortLabel)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
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
                        selectedRecipientID = r.id
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
                                .fill(selectedRecipientID == r.id ? AppShellTheme.accent.opacity(0.15) : .clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .strokeBorder(selectedRecipientID == r.id ? AppShellTheme.accent : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var ctmExplainer: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(AppShellTheme.gold)
                    Text("How a CTM works")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppShellTheme.title)
                }
                Text("Once the recipient activates it, you receive 30 daily check-ins. If you don't decline any of them, the message releases on day 30.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var continueButton: some View {
        Button {
            Haptics.feedback(style: .medium)
            goToComposer = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: medium.icon)
                Text(continueTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(canContinue ? AppShellTheme.accent : AppShellTheme.subtitle.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .disabled(!canContinue)
    }

    private var continueTitle: String {
        switch medium {
        case .video: return "Record video"
        case .voice: return "Record voice note"
        case .photo: return "Add photo & note"
        case .text:  return "Write message"
        }
    }
}
