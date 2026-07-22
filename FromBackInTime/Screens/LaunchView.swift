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
    @Environment(MockAppStore.self) private var store
    @Environment(AuthStore.self) private var authStore
    @Environment(PaywallManager.self) private var paywall

    @State private var pulsing = false
    @State private var spinning = false
    @State private var isRetrying = false

    private var failureMessage: String? {
        if case .failed(let message) = store.bootstrapPhase { return message }
        return nil
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Spacer()

                Image("ob-app-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 108, height: 108)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .shadow(color: AppShellTheme.accent.opacity(0.3), radius: 26, y: 12)
                    .scaleEffect(pulsing ? 1.06 : 0.96)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulsing)
                    .padding(.bottom, AppSpacing.xxl)

                if let failureMessage {
                    errorContent(failureMessage)
                } else {
                    loadingContent
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, AppSpacing.xxl)
        }
        .onAppear {
            pulsing = true
            spinning = true
        }
        .a11y("launch.screen")
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
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppShellTheme.title)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.system(size: 15, weight: .medium, design: .rounded))
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
                    .padding(.vertical, AppSpacing.lg)
                    .background(RoundedRectangle(cornerRadius: AppRadius.lg).fill(AppShellTheme.accent))
            }
            .buttonStyle(.plain)
            .disabled(isRetrying)
            .padding(.top, AppSpacing.sm)
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
