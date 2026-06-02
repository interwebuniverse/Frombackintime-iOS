//
//  CreateView.swift
//  FromBackInTime
//
//  Entry point to making a message. Two choices the user makes here:
//  1) Kind — a normal timed message vs a Critical Timed Message (the
//     dead-man's-switch)
//  2) Medium — how the message reaches the recipient: video, voice,
//     photo + note, or written words.
//  After this we push CreateFormView to fill in the details, then a
//  composer matched to the chosen medium.
//

import SwiftUI

struct CreateView: View {
    @Environment(\.dismiss) private var dismiss

    let initialRecipient: Recipient?
    let initialKind: MessageKind?

    @State private var kind: MessageKind = .standard

    init(initialRecipient: Recipient? = nil, initialKind: MessageKind? = nil) {
        self.initialRecipient = initialRecipient
        self.initialKind = initialKind
        self._kind = State(initialValue: initialKind ?? .standard)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    kindToggle
                    mediumPicker
                }
                .padding(AppShellTheme.screenPadding)
                .padding(.bottom, AppSpacing.xxxl)
            }
            .background(AppBackground())
            .scrollContentBackground(.hidden)
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AppShellTheme.accent)
                }
            }
        }
    }

    // MARK: - Kind toggle (Timed / Critical Timed)

    private var kindToggle: some View {
        HStack(spacing: 0) {
            kindPill(label: "Timed", kindValue: .standard, tint: AppShellTheme.accent)
            kindPill(label: "Critical timed", kindValue: .ctm, tint: AppShellTheme.gold)
        }
        .padding(4)
        .background(
            Capsule().fill(.white.opacity(0.7))
        )
        .overlay(
            Capsule().strokeBorder(AppShellTheme.subtitle.opacity(0.12), lineWidth: 1)
        )
    }

    private func kindPill(label: String, kindValue: MessageKind, tint: Color) -> some View {
        let active = kind == kindValue
        return Button {
            Haptics.selection()
            withAnimation(.easeInOut(duration: 0.18)) { kind = kindValue }
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(active ? .white : AppShellTheme.title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(active ? tint : .clear))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Medium picker

    private var mediumPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("How do you want to send it?")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .textCase(.uppercase)

            VStack(spacing: AppSpacing.md) {
                ForEach(MessageMedium.allCases) { medium in
                    NavigationLink(value: CreateRoute(kind: kind, medium: medium, recipient: initialRecipient)) {
                        MediumCard(medium: medium)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationDestination(for: CreateRoute.self) { route in
            CreateFormView(kind: route.kind, medium: route.medium, prefilledRecipient: route.recipient)
        }
    }
}

// MARK: - Route value (kind + medium + recipient)

struct CreateRoute: Hashable {
    let kind: MessageKind
    let medium: MessageMedium
    let recipient: Recipient?
}

// MARK: - Medium card

struct MediumCard: View {
    let medium: MessageMedium

    private var tint: Color { Color(hue: medium.hue, saturation: 0.62, brightness: 0.92) }
    private var deepTint: Color { Color(hue: medium.hue, saturation: 0.75, brightness: 0.6) }

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            iconBlob
            VStack(alignment: .leading, spacing: 4) {
                Text(medium.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                Text(medium.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppShellTheme.subtitle.opacity(0.6))
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .strokeBorder(tint.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.15), radius: 14, y: 6)
    }

    private var iconBlob: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.85), deepTint.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .shadow(color: deepTint.opacity(0.4), radius: 10, y: 4)
            Image(systemName: medium.icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    CreateView()
        .environment(MockAppStore())
        .environment(AppState())
}
