//
//  AppState.swift
//  FromBackInTime
//
//  App-level state that outlives any single screen. Decides whether the
//  user sees onboarding or the main tab bar. Injected via .environment().
//

import SwiftUI

@MainActor
@Observable
final class AppState {
    private static let onboardedKey = "hasCompletedOnboarding"

    var hasCompletedOnboarding: Bool

    /// Set when the user chose "Record my first message" at the end of
    /// onboarding; RootView opens the create sheet right after the swap.
    var pendingFirstCreate = false

    /// A first message recorded during onboarding, waiting to be saved once
    /// the paywall unlocks and (if needed) the user signs in. Held in memory
    /// only: the video bytes are too large to persist and the flow completes
    /// in one sitting.
    struct FirstMessagePayload {
        var recipientName: String
        var recipientEmail: String
        var occasion: String
        var deliveryDate: Date
        var videoData: Data
        var contentType: String
        var durationSeconds: Int
    }
    var pendingFirstMessage: FirstMessagePayload?

    init() {
        #if MOCK
        // The Mock scheme (automated suite + demos) starts past onboarding as a
        // signed-in, subscribed test user; onboarding itself is exercised on the
        // live scheme. Set synchronously so the suite never asserts during the
        // brief onboarding window while the launch task establishes the session.
        hasCompletedOnboarding = true
        #else
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Self.onboardedKey)
        #endif
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: Self.onboardedKey)
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: Self.onboardedKey)
    }
}
