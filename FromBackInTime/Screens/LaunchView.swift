//
//  LaunchView.swift
//  FromBackInTime
//
//  Cold-launch screen: the app logo pulsing over the sky with a spinning ring
//  under it while the session and vault load. If loading fails it says why in
//  plain words, offers a retry, and a one-tap support email that already
//  carries the user id and app version so nobody has to explain themselves.
//

import SwiftUI
import UIKit

struct LaunchView: View {
    @Environment(AppState.self) private var appState
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore
    @Environment(PaywallManager.self) private var paywall

    @State private var pulsing = false
    @State private var spinning = false
    @State private var isRetrying = false
    @State private var gateArmed = false

    private var failureMessage: String? {
        if case .failed(let message) = store.bootstrapPhase { return message }
        return nil
    }

    /// Loaded, onboarded, not subscribed: this view stays put as the calm
    /// backdrop and the hard paywall presents over it. No second screen, no
    /// second loader.
    private var isGate: Bool {
        store.bootstrapPhase == .ready && appState.hasCompletedOnboarding && !paywall.hasAccess
    }

    var body: some View {
        ZStack {
            AppBackground()

            // Everything lives in one dead-centered column: glow, icon,
            // wordmark, then the single ring (or the error card).
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(AppShellTheme.accent.opacity(0.14))
                        .frame(width: 168, height: 168)
                        .blur(radius: 24)
                        .scaleEffect(pulsing ? 1.12 : 0.9)
                    Image("ob-app-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 112, height: 112)
                        .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 27, style: .continuous)
                                .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: AppShellTheme.accent.opacity(0.35), radius: 28, y: 14)
                        .scaleEffect(pulsing ? 1.05 : 0.97)
                }
                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: pulsing)
                .padding(.bottom, AppSpacing.lg)

                Text("FromBackInTime")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppShellTheme.title)
                Text("Messages that outlive the moment")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppShellTheme.subtitle)
                    .padding(.top, 2)

                if let failureMessage {
                    errorContent(failureMessage)
                        .padding(.top, AppSpacing.xxl)
                } else if !isGate {
                    loadingContent
                        .padding(.top, AppSpacing.xxl)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, AppSpacing.xxl)
        }
        .onAppear {
            pulsing = true
            spinning = true
            armGateIfNeeded()
        }
        .onChange(of: isGate) { _, _ in armGateIfNeeded() }
        .a11y("launch.screen")
    }

    /// Raise the gated paywall exactly once per lock-in; its own handler
    /// re-presents on decline, so no loop here.
    private func armGateIfNeeded() {
        if isGate {
            guard !gateArmed else { return }
            gateArmed = true
            paywall.requireAccess()
        } else {
            gateArmed = false
        }
    }

    // MARK: - Loading

    private var loadingContent: some View {
        VStack(spacing: AppSpacing.md) {
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(AppShellTheme.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(spinning ? 360 : 0))
                .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: spinning)
            Text("Opening your vault\u{2026}")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
        }
        .transition(.opacity)
    }

    // MARK: - Error

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text("We couldn't open your vault")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppShellTheme.subtitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Haptics.selection()
                retry()
            } label: {
                Text(isRetrying ? "Trying again\u{2026}" : "Try again")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md + 2)
                    .background(RoundedRectangle(cornerRadius: AppRadius.lg).fill(AppShellTheme.accent))
            }
            .buttonStyle(.plain)
            .disabled(isRetrying)
            .padding(.top, AppSpacing.xs)
            .a11y("launch.retry")

            Button {
                Haptics.selection()
                openSupportEmail()
            } label: {
                Text("Email support")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppShellTheme.accent)
            }
            .buttonStyle(.plain)
            .a11y("launch.support")
        }
        .padding(AppSpacing.xl)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppShellTheme.cardRadius, style: .continuous)
                .strokeBorder(AppShellTheme.cardBorder, lineWidth: 1)
        )
        .shadow(color: AppShellTheme.cardShadow, radius: 16, y: 8)
        .transition(.opacity)
    }

    /// Redo the whole launch chain, not just the data load: a failed launch is
    /// usually a dead session or no network, so the session comes first.
    private func retry() {
        guard !isRetrying else { return }
        isRetrying = true
        Task {
            await authStore.ensureSession()
            paywall.identify(userId: authStore.state.userId)
            await store.bootstrap()
            await authStore.loadProfile()
            isRetrying = false
        }
    }

    /// Opens Mail with the support address and a body that already carries the
    /// user id + app + OS versions, so support can find the account instantly.
    private func openSupportEmail() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        let body = """


        ----
        User ID: \(authStore.state.userId ?? "not signed in")
        App version: \(version) (\(build))
        iOS: \(UIDevice.current.systemVersion)
        """
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "support@frombackintime.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "FromBackInTime support"),
            URLQueryItem(name: "body", value: body),
        ]
        guard let url = components.url else { return }
        UIApplication.shared.open(url)
    }
}
