//
//  MessageRow.swift
//  FromBackInTime
//
//  One row in any message list (Home upcoming, Library, Icon page). Tappable
//  to open a placeholder message detail.
//

import SwiftUI

struct MessageRow: View {
    @Environment(MockAppStore.self) private var store
    let message: Message

    private var recipient: Recipient? { store.recipient(id: message.recipientID) }

    var body: some View {
        AppCard(padding: AppSpacing.lg) {
            HStack(spacing: AppSpacing.lg) {
                if let recipient {
                    RecipientAvatar(recipient: recipient, size: 48)
                } else {
                    Circle().fill(AppShellTheme.subtitle.opacity(0.2)).frame(width: 48, height: 48)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: AppSpacing.xs) {
                        Text(recipient?.name ?? "Unknown")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppShellTheme.title)
                        mediumBadge
                        if message.kind == .ctm {
                            ctmBadge
                        }
                    }
                    Text(message.occasion)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                    Text(dateLabel)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppShellTheme.accent)
                        .padding(.top, 2)
                }
                Spacer(minLength: 0)
                AppIcon(name: "app-ic-chevron", size: 15, color: AppShellTheme.faint)
            }
        }
        .a11y("message.row")
    }

    private var ctmBadge: some View {
        Text(message.ctmActivated ? "Activated" : "CTM")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(message.ctmActivated ? AppShellTheme.accent : AppShellTheme.gold)
            )
    }

    private var mediumBadge: some View {
        let tint = Color(hue: message.medium.hue, saturation: 0.55, brightness: 0.7)
        return HStack(spacing: 4) {
            AppIcon(name: message.medium.glyph, size: 10, color: tint)
            Text(message.medium.shortLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Capsule().fill(tint.opacity(0.14)))
    }

    private var dateLabel: String {
        if let d = message.deliveryDate {
            return "Delivers \(DateFormatter.prettyDate.string(from: d))"
        }
        return message.kind == .ctm ? "Awaiting activation" : "Date TBD"
    }
}
