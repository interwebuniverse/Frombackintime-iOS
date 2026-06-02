//
//  AppShellTheme.swift
//  FromBackInTime
//
//  Tokens for the main app shell (tab bar + base screens). Carries the
//  sky-blue accent and warm gold from the onboarding so the post-onboarding
//  app feels like the same product. Change here to retune the shell.
//

import SwiftUI

enum AppShellTheme {
    /// Sky-blue accent used for tab tint, primary actions, active states.
    static let accent = Color(red: 46/255, green: 128/255, blue: 238/255)
    /// Warm gold for premium / CTM accents.
    static let gold = Color(red: 232/255, green: 173/255, blue: 60/255)

    static let background = Color.appBackground
    static let card = Color.white
    /// Asset name for the shared soft cloudscape used behind every main screen.
    static let backgroundImage = "app-bg-clouds"
    /// Cream colour sampled from the bottom of the cloud image. Used as the
    /// solid fall-back fill and the bottom of the legibility scrim so cards
    /// blend into the photo without a visible seam.
    static let backgroundBottom = Color(red: 248/255, green: 238/255, blue: 220/255)
    static let title = Color.appPrimary
    static let subtitle = Color.appSecondary

    static let cardShadow = Color.black.opacity(0.06)
    static let cardRadius: CGFloat = AppRadius.lg
    /// 20pt matches the system large-title leading inset so the body and nav
    /// title line up on the left edge.
    static let screenPadding: CGFloat = AppSpacing.xl
}
