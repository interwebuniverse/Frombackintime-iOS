//
//  MessageScheduledView.swift
//  FromBackInTime
//
//  Shown right after a message is sealed, so there is never a doubt about
//  whether it worked. Big check, who it's for, exactly when it arrives, and
//  one Done button that closes the whole create flow.
//

import SwiftUI
import UIKit

struct MessageScheduledView: View {
    let recipientName: String
    let medium: MessageMedium
    let kind: MessageKind
    let deliveryDate: Date?

    @State private var showCheck = false

    private var mediumWord: String {
        switch medium {
        case .video: return "video"
        case .voice: return "voice note"
        case .photo: return "photo message"
        case .text: return "message"
        }
    }

    private var whenLine: String {
        guard kind == .standard, let deliveryDate else {
            return "It stays sealed and releases only if your check-ins stop."
        }
        return "It arrives \(deliveryDate.friendlyArrival)."
    }

    private var dateLine: String? {
        guard kind == .standard, let deliveryDate else { return nil }
        return "\(DateFormatter.prettyDateTime.string(from: deliveryDate)), your local time"
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(AppShellTheme.accent.opacity(0.14))
                        .frame(width: 132, height: 132)
                    Circle()
                        .fill(AppShellTheme.accent)
                        .frame(width: 96, height: 96)
                        .shadow(color: AppShellTheme.accent.opacity(0.45), radius: 24, y: 10)
                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .heavy))
                        .foregroundStyle(.white)
                }
                .scaleEffect(showCheck ? 1 : 0.4)
                .opacity(showCheck ? 1 : 0)
                .padding(.bottom, AppSpacing.xxl)

                VStack(spacing: AppSpacing.sm) {
                    Text(kind == .ctm ? "Sealed and standing by" : "Sealed and scheduled")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppShellTheme.title)
                        .multilineTextAlignment(.center)

                    Text("Your \(mediumWord) for \(recipientName) is safe. \(whenLine)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppShellTheme.subtitle)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if let dateLine {
                        HStack(spacing: AppSpacing.sm) {
                            AppIcon(name: "app-ic-calendar", size: 18, color: AppShellTheme.accent)
                            Text(dateLine)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(AppShellTheme.title)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                        .background(.white.opacity(0.8), in: Capsule())
                        .overlay(Capsule().strokeBorder(AppShellTheme.cardBorder, lineWidth: 1))
                        .padding(.top, AppSpacing.md)
                    }
                }
                .padding(.horizontal, AppSpacing.xxl)

                Spacer()

                Button {
                    Haptics.notification(type: .success)
                    NotificationCenter.default.post(name: .createFlowFinished, object: nil)
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.lg)
                        .background(RoundedRectangle(cornerRadius: AppRadius.lg).fill(AppShellTheme.accent))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppShellTheme.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
                .a11y("scheduled.done")
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            // The composer's editor may still hold focus; a keyboard has no
            // business on a confirmation screen.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1)) {
                showCheck = true
            }
        }
        .a11y("scheduled.screen")
    }
}

// MARK: - Composer hook

extension View {
    /// Full-screen confirmation over a composer once its message is sealed.
    /// Pass the store-clamped delivery date so the screen shows what was
    /// actually scheduled.
    func scheduledCover(
        _ isPresented: Bool,
        recipientName: String,
        medium: MessageMedium,
        kind: MessageKind,
        deliveryDate: Date?
    ) -> some View {
        overlay {
            if isPresented {
                MessageScheduledView(
                    recipientName: recipientName,
                    medium: medium,
                    kind: kind,
                    deliveryDate: deliveryDate
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

// MARK: - Composer top bar

/// The one top bar every composer uses: close on the left, recipient +
/// occasion in the middle. `dark` matches the video/voice full-bleed look;
/// light sits on the sky for photo/text.
struct ComposerTopBar: View {
    let recipientName: String
    let occasion: String
    var fallback: String = "Message"
    var dark: Bool = false
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button {
                Haptics.selection()
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(dark ? .white : AppShellTheme.title)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle().fill(dark ? .white.opacity(0.15) : .white.opacity(0.75))
                    )
                    .overlay(Circle().strokeBorder(.white.opacity(dark ? 0 : 0.7), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .a11y("composer.close")
            Spacer()
            VStack(spacing: 2) {
                Text(recipientName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(dark ? .white : AppShellTheme.title)
                Text(occasion.isEmpty ? fallback : occasion)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(dark ? .white.opacity(0.75) : AppShellTheme.subtitle)
            }
            Spacer()
            Color.clear.frame(width: 42, height: 42)
        }
    }
}
