//
//  PaywallGateView.swift
//  FromBackInTime
//
//  The locked state shown after onboarding when the user isn't subscribed. It
//  presents the Superwall hard paywall over a calm backdrop; the app stays out
//  of reach until an entitlement is active, at which point RootView swaps to the
//  tab bar.
//

import SwiftUI

struct PaywallGateView: View {
    @Environment(PaywallManager.self) private var paywall

    var body: some View {
        ZStack {
            AppBackground()
                .ignoresSafeArea()
            // A calm branded backdrop while the paywall slides over. No
            // spinner: the only spinner in the app lives on LaunchView.
            Image("ob-app-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: AppShellTheme.accent.opacity(0.3), radius: 22, y: 10)
        }
        .task { paywall.requireAccess() }
    }
}
