//
//  CreateFormView.swift
//  FromBackInTime
//
//  The "who, what, when" form, laid out as three numbered steps so anyone can
//  follow it: pick the person, name the occasion, choose when it arrives.
//  "When" starts from plain-language presets (tomorrow, in a year...) and only
//  opens the full calendar when the user asks for a specific date. A big
//  always-visible "Arrives ..." line repeats exactly what will happen.
//  CTM messages skip "when": they release when the switch trips.
//

import SwiftUI

struct CreateFormView: View {
    @Environment(MockAppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let kind: MessageKind
    let medium: MessageMedium
    let prefilledRecipient: Recipient?

    @State private var selectedRecipientID: String?
    @State private var occasion: String = ""
    @State private var deliveryDate: Date = DeliveryPreset.year.date
    @State private var preset: DeliveryPreset? = .year
    @State private var goToComposer: Bool = false
    @State private var showAddPerson = false

    /// Delivery can be any future moment, even a couple of minutes from now.
    /// If the pick slips behind the clock while recording, the store bumps it
    /// forward at save instead of failing.
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
        AppNavScrollView(
            title: kind == .ctm ? "Set up your CTM" : "Set it up",
            leading: .back { dismiss() }
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                kindHeader

                step(number: 1, title: "Who is it for?") {
                    recipientPicker
                        .a11y("form.recipient")
                }

                step(number: 2, title: "What's the occasion?") {
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
                    step(number: 3, title: "When should it arrive?") {
                        whenPicker
                    }
                } else {
                    ctmExplainer
                }

                continueButton
            }
            .padding(.horizontal, AppShellTheme.screenPadding)
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

    /// Numbered step section: a small accent circle with the step number and
    /// a plain-language question as the title.
    @ViewBuilder
    private func step<C: View>(number: Int, title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Text("\(number)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(AppShellTheme.accent))
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
            }
            content()
        }
    }

    // MARK: - When picker (presets first, calendar on demand)

    private var whenPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            presetGrid

            if preset == nil {
                VStack(spacing: 0) {
                    DatePicker("", selection: $deliveryDate, in: earliestDelivery..., displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.graphical)
                        // The graphical picker doesn't reliably keep the time
                        // wheel inside the range; snap forward here.
                        .onChange(of: deliveryDate) { _, picked in
                            let floor = earliestDelivery
                            if picked < floor { deliveryDate = floor }
                        }
                        .a11y("form.date")
                }
                .padding(AppSpacing.md)
                .background(AppShellTheme.card, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                .shadow(color: AppShellTheme.cardShadow, radius: 10, y: 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            arrivesCard
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: preset)
    }

    private var presetGrid: some View {
        let columns = [GridItem(.flexible(), spacing: AppSpacing.sm), GridItem(.flexible(), spacing: AppSpacing.sm)]
        return LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
            ForEach(DeliveryPreset.allCases) { p in
                presetChip(label: p.label, selected: preset == p) {
                    preset = p
                    deliveryDate = p.date
                }
            }
            presetChip(label: "Pick a date...", selected: preset == nil) {
                preset = nil
            }
        }
    }

    private func presetChip(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(selected ? .white : AppShellTheme.title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(selected ? AppShellTheme.accent : .white.opacity(0.75))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .strokeBorder(selected ? .clear : AppShellTheme.subtitle.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    /// The one line that spells out exactly what will happen. Impossible to
    /// schedule for next year thinking it's tonight.
    private var arrivesCard: some View {
        HStack(spacing: AppSpacing.sm) {
            AppIcon(name: "app-ic-calendar", size: 20, color: AppShellTheme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Arrives \(relativeArrival)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                Text("\(DateFormatter.prettyDateTime.string(from: deliveryDate)), your local time")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle)
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .background(AppShellTheme.accentSoft, in: RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .strokeBorder(AppShellTheme.accent.opacity(0.25), lineWidth: 1)
        )
    }

    /// Use the preset's own words when one is picked so the summary never
    /// contradicts the selected chip; custom dates get the rounded wording.
    private var relativeArrival: String {
        if let preset {
            return preset == .tomorrow ? "tomorrow" : preset.label.lowercased()
        }
        return deliveryDate.friendlyArrival
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
                    addPersonTile
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var addPersonTile: some View {
        Button {
            Haptics.selection()
            showAddPerson = true
        } label: {
            VStack(spacing: AppSpacing.xs) {
                ZStack {
                    Circle()
                        .strokeBorder(AppShellTheme.accent.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .frame(width: 54, height: 54)
                    AppIcon(name: "app-ic-plus", size: 22, color: AppShellTheme.accent)
                }
                Text("Add")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppShellTheme.accent)
            }
            .padding(AppSpacing.sm)
        }
        .buttonStyle(.plain)
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

// MARK: - Delivery presets

/// Plain-language delivery choices. Presets land at 9:00 in the morning local
/// time, a moment that reads naturally for "it arrives that day".
enum DeliveryPreset: CaseIterable, Identifiable {
    case tomorrow, week, month, year, fiveYears

    var id: Self { self }

    var label: String {
        switch self {
        case .tomorrow: return "Tomorrow"
        case .week: return "In a week"
        case .month: return "In a month"
        case .year: return "In a year"
        case .fiveYears: return "In 5 years"
        }
    }

    var date: Date {
        let cal = Calendar.current
        let base: Date
        switch self {
        case .tomorrow: base = cal.date(byAdding: .day, value: 1, to: .now) ?? .now
        case .week: base = cal.date(byAdding: .day, value: 7, to: .now) ?? .now
        case .month: base = cal.date(byAdding: .month, value: 1, to: .now) ?? .now
        case .year: base = cal.date(byAdding: .year, value: 1, to: .now) ?? .now
        case .fiveYears: base = cal.date(byAdding: .year, value: 5, to: .now) ?? .now
        }
        return cal.date(bySettingHour: 9, minute: 0, second: 0, of: base) ?? base
    }
}
