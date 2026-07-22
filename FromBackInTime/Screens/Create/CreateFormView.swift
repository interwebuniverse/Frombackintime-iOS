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

    @State private var selectedRecipientID: String?
    @State private var occasion: String = ""
    @State private var deliveryDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: .now) ?? .now
    @State private var goToComposer: Bool = false
    @State private var showAddPerson = false

    /// Delivery can be any future moment, even a couple of minutes from now.
    /// If the pick slips behind the clock while recording, the store bumps it
    /// forward at save instead of failing. The picked Date is an absolute
    /// instant, so the ISO-8601 string the backend gets is timezone-correct
    /// as is.
    private var earliestDelivery: Date {
        .now.addingTimeInterval(2 * 60)
    }

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
                        .a11y("form.recipient")
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
                        .a11y("form.occasion")
                }

                if kind == .standard {
                    section(title: "Delivery date & time") {
                        VStack(spacing: 0) {
                            DatePicker("", selection: $deliveryDate, in: earliestDelivery..., displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .datePickerStyle(.graphical)
                                // The graphical picker doesn't reliably keep the
                                // time wheel inside the range; snap forward here.
                                .onChange(of: deliveryDate) { _, picked in
                                    let floor = earliestDelivery
                                    if picked < floor { deliveryDate = floor }
                                }
                                .a11y("form.date")
                            Text("Your local time. We deliver on the minute.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppShellTheme.subtitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
        .scrollDismissesKeyboard(.immediately)
        .navigationDestination(isPresented: $goToComposer) {
            if let id = selectedRecipientID, let recipient = store.recipient(id: id) {
                composer(for: recipient)
            }
        }
        .sheet(isPresented: $showAddPerson) {
            AddPersonView()
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
        }
        .a11y("form.screen")
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
            AppIcon(name: kind == .ctm ? "app-ic-shield" : "app-ic-send", size: 15,
                    color: kind == .ctm ? AppShellTheme.gold : AppShellTheme.accent)
            Text(kind == .ctm ? "Critical Timed Message" : "Timed message")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
            Text("·")
                .foregroundStyle(AppShellTheme.subtitle.opacity(0.6))
            AppIcon(name: medium.glyph, size: 15, color: Color(hue: medium.hue, saturation: 0.7, brightness: 0.6))
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

    @ViewBuilder
    private var recipientPicker: some View {
        if store.recipients.isEmpty {
            Button {
                Haptics.selection()
                showAddPerson = true
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    AppIcon(name: "app-ic-plus", size: 20, color: AppShellTheme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add someone first")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                        Text("Every message is for a person. Add one to begin.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppShellTheme.subtitle)
                    }
                    Spacer(minLength: 0)
                }
                .padding(AppSpacing.md)
                .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .strokeBorder(AppShellTheme.accent.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        } else {
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
    }

    private var ctmExplainer: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.sm) {
                    AppIcon(name: "app-ic-shield", size: 16, color: AppShellTheme.gold)
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
                AppIcon(name: medium.glyph, size: 17, color: .white)
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
        .a11y("form.continue")
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
