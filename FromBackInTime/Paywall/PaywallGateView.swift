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
            // A quiet placeholder in case the paywall takes a beat to load.
            ProgressView()
                .tint(AppShellTheme.accent)
        }
        .task { paywall.requireAccess() }
    }
}
