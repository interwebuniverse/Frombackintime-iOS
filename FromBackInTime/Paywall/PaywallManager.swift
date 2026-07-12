//
//  PaywallManager.swift
//  FromBackInTime
//
//  Owns the Superwall lifecycle and mirrors its entitlement status into
//  observable app state. The app is hard-gated: after onboarding, a user who
//  isn't subscribed is shown the Superwall paywall and can't reach the app
//  until they pay (see RootView + PaywallGateView).
//

import Combine
import SwiftUI
import SuperwallKit

@MainActor
@Observable
final class PaywallManager {
    /// True once the user holds an active entitlement (has paid).
    private(set) var isSubscribed = false

    /// True until Superwall reports a definitive status. Prevents flashing the
    /// paywall over a user who is actually subscribed on a cold launch.
    private(set) var isResolving = true

    @ObservationIgnored private var configured = false
    @ObservationIgnored private var statusObserver: AnyCancellable?

    init() {
        #if MOCK
        // Mock scheme is a subscribed test user; resolve synchronously so the
        // suite/demo never sees the gate spinner while configure() runs.
        isSubscribed = true
        isResolving = false
        #endif
    }

    /// Configure Superwall once at launch and start mirroring its subscription
    /// status. Safe to call more than once.
    func configure() {
        guard !configured else { return }
        configured = true

        #if MOCK
        // The Mock scheme runs as a subscribed test user so the automated suite
        // (and demos) aren't blocked by the hard paywall. Live builds gate.
        isSubscribed = true
        isResolving = false
        return
        #else
        Superwall.configure(apiKey: SuperwallConfig.apiKey)

        statusObserver = Superwall.shared.$subscriptionStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .active:
                    self.isSubscribed = true
                    self.isResolving = false
                case .inactive:
                    self.isSubscribed = false
                    self.isResolving = false
                case .unknown:
                    self.isResolving = true
                @unknown default:
                    self.isResolving = false
                }
            }
        #endif
    }

    /// Present the hard paywall for the gate placement. With a **Gated** campaign
    /// the `feature` closure runs only if the user is already paying or begins
    /// paying; a purchase/restore flips `subscriptionStatus` to `.active`, which
    /// unlocks the app. If the user closes the paywall without paying, it is
    /// re-presented so there's no way into the app without subscribing.
    func presentGate() {
        #if MOCK
        return
        #else
        let handler = PaywallPresentationHandler()
        handler.onDismiss { [weak self] _, result in
            guard let self else { return }
            if case .declined = result, !self.isSubscribed {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(300))
                    self.presentGate()
                }
            }
        }
        Superwall.shared.register(placement: SuperwallConfig.gatePlacement, handler: handler) {
            // The status publisher above drives the UI once entitled; nothing to
            // do here beyond letting Superwall dismiss the paywall.
        }
        #endif
    }

    /// Tie Superwall's identity to the app's account so entitlements follow the
    /// user across devices. Call after a session is established.
    func identify(userId: String?) {
        #if MOCK
        return
        #else
        guard let userId, !userId.isEmpty else { return }
        Superwall.shared.identify(userId: userId)
        #endif
    }

    /// Clear Superwall's identity (e.g. on account deletion).
    func reset() {
        #if MOCK
        return
        #else
        Superwall.shared.reset()
        #endif
    }
}
