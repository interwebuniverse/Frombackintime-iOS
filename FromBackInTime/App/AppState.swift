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

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Self.onboardedKey)
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
