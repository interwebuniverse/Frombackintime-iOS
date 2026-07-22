//
//  PaywallManager.swift
//  FromBackInTime
//
//  Owns the Superwall lifecycle and the hard gate. The app is gated by *calling
//  register every time* access is needed (end of onboarding, and every launch
//  once onboarding is done). With a Gated campaign, Superwall itself decides:
//  if the user is entitled the `feature` closure runs immediately and unlocks
//  the app; if not, Superwall shows the paywall and the closure only runs after
//  they subscribe. We don't watch subscriptionStatus, register is the source of
//  truth (see RootView + PaywallGateView).
//

import SwiftUI
import SuperwallKit

@MainActor
@Observable
final class PaywallManager {
    /// Flipped true only from inside register's `feature` closure, i.e. when
    /// Superwall confirms the user has access. Drives RootView into the app.
    private(set) var hasAccess = false

    @ObservationIgnored private var configured = false

    init() {
        #if MOCK
        // Mock scheme is an entitled test user so the suite/demo isn't gated.
        hasAccess = true
        #endif
    }

    /// Configure Superwall once at launch. Safe to call more than once.
    func configure() {
        guard !configured else { return }
        configured = true
        #if !MOCK
        let options = SuperwallOptions()
        #if DEBUG
        // Debug builds always run Superwall in test mode: the paywall shows
        // and purchases run as test transactions, never live ones.
        options.testModeBehavior = .always
        #endif
        Superwall.configure(apiKey: SuperwallConfig.apiKey, options: options)
        #endif
    }

    /// Gate the app. Call this every time we need access (onboarding end + each
    /// launch once onboarding is finished). `register` re-checks entitlement on
    /// every call: entitled → `feature` runs now and unlocks; not entitled →
    /// the Gated paywall is presented and `feature` only runs after they pay. A
    /// dismissal without access re-presents it so there's no way in without a sub.
    /// `onAccess` runs inside the feature closure, right after access is granted;
    /// onboarding uses it to finish itself only once the user is through the gate.
    func requireAccess(onAccess: (() -> Void)? = nil) {
        #if MOCK
        hasAccess = true
        onAccess?()
        return
        #else
        let handler = PaywallPresentationHandler()
        handler.onDismiss { [weak self] _, result in
            guard let self else { return }
            if case .declined = result, !self.hasAccess {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(300))
                    self.requireAccess(onAccess: onAccess)
                }
            }
        }
        Superwall.shared.register(placement: SuperwallConfig.gatePlacement, handler: handler) { [weak self] in
            // Runs only when the user has access (already paying or just paid).
            self?.hasAccess = true
            onAccess?()
        }
        #endif
    }

    /// Tie Superwall's identity to the app's account so entitlements follow the
    /// user across devices. Call after a session is established.
    func identify(userId: String?) {
        #if !MOCK
        guard let userId, !userId.isEmpty else { return }
        Superwall.shared.identify(userId: userId)
        #endif
    }

    /// Clear Superwall's identity (e.g. on account deletion).
    func reset() {
        #if !MOCK
        Superwall.shared.reset()
        hasAccess = false
        #endif
    }
}
