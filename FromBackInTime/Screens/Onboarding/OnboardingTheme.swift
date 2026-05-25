//
//  OnboardingTheme.swift
//  FromBackInTime
//
//  Single source of truth for every color, spacing, and timing value the
//  onboarding uses. Nothing in the onboarding screens hardcodes a color.
//  To rebrand the whole flow (cream + black, indigo + gold, etc.), change
//  the values here. These map to the global tokens in Color+App.swift, so
//  you can also rebrand globally and the onboarding follows.
//

import SwiftUI

enum OnboardingTheme {

    // MARK: - Surfaces

    /// Default page background. One light surface across the whole flow.
    static let background = Color.appBackground
    /// Kept as a token name for the "feature/hero" screens, now also light
    /// so the onboarding stays one consistent colour.
    static let cinematicBackground = Color.appBackground
    /// Card / chip / answer-row fill. Solid white so it reads on the sky-photo
    /// backgrounds used across the flow.
    static let card = Color.white
    /// Placeholder image fill.
    static let placeholderFill = Color.appInputBackground

    // MARK: - Text

    static let title = Color.appPrimary
    static let subtitle = Color.appSecondary
    /// Text on the former-cinematic screens, now dark on light.
    static let onCinematic = Color.appPrimary
    static let onCinematicSubtitle = Color.appSecondary
    static let placeholderText = Color.appSecondary

    // MARK: - Selection (quiz answers, chips)

    /// Fill of a selected answer.
    static let selectedFill = Color.appPrimary
    /// Text/icon color on a selected answer.
    static let onSelected = Color.appBackground
    /// Text color on an unselected answer.
    static let onUnselected = Color.appPrimary

    // MARK: - Accent (emotional highlights, glows, progress)

    static let accent = Color.appPrimary          // swap to a warm clay/gold later
    /// Bluish highlight for emotionally important words on the sky screens.
    static let highlight = Color(red: 46/255, green: 128/255, blue: 238/255)
    /// Warm gold for star ratings and accolade laurels.
    static let gold = Color(red: 232/255, green: 173/255, blue: 60/255)
    static let progressTrack = Color.appBorder
    static let progressFill = Color.appPrimary

    // MARK: - Layout

    static let screenPadding: CGFloat = AppSpacing.xxl     // 24
    static let bottomPadding: CGFloat = AppSpacing.xxl      // 24
    static let stackSpacing: CGFloat = AppSpacing.lg        // 16
    static let answerSpacing: CGFloat = AppSpacing.md       // 12
    static let answerCornerRadius: CGFloat = AppRadius.lg   // 16
    static let cardCornerRadius: CGFloat = AppRadius.lg     // 16

    // MARK: - Motion

    /// Spring used for every press / selection bounce.
    static let bounce = Animation.spring(response: 0.35, dampingFraction: 0.6)
    /// Transition between questions inside a quiz block.
    static let questionSwap = Animation.spring(response: 0.45, dampingFraction: 0.8)
    /// Count-up duration for numbers.
    static let countUp: TimeInterval = 1.1
}
