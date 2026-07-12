//
//  AppShellTheme.swift
//  FromBackInTime
//
//  Design tokens for the main app shell (tab bar + base screens). One place to
//  retune the post-onboarding look: a calm cool canvas, crisp white cards, a
//  refined blue accent carried from the onboarding sky, and a warm amber for
//  the Critical Timed Message accents.
//

import SwiftUI

enum AppShellTheme {
    // MARK: Accents
    /// Primary blue: actions, active states, links. A touch deeper than the
    /// onboarding sky so it reads crisp on the light canvas.
    static let accent = Color(red: 0x25/255, green: 0x63/255, blue: 0xEB/255)
    /// Faint accent wash for chips / selected fills.
    static let accentSoft = accent.opacity(0.10)
    /// Warm amber for premium / CTM accents.
    static let gold = Color(red: 0xDF/255, green: 0x9E/255, blue: 0x30/255)
    static let goldSoft = Color(red: 0xDF/255, green: 0x9E/255, blue: 0x30/255).opacity(0.14)

    // MARK: Text
    /// Bluish charcoal — softer and more designed than pure black.
    static let title = Color(red: 0x1B/255, green: 0x20/255, blue: 0x30/255)
    static let subtitle = Color(red: 0x6B/255, green: 0x73/255, blue: 0x85/255)
    static let faint = Color(red: 0x9A/255, green: 0xA1/255, blue: 0xB0/255)

    // MARK: Surfaces
    static let card = Color.white
    /// Hairline drawn around cards for crispness on the light canvas.
    static let cardBorder = Color.black.opacity(0.05)
    static let cardShadow = Color(red: 0x1B/255, green: 0x20/255, blue: 0x30/255).opacity(0.05)
    static let cardRadius: CGFloat = 22

    /// Cool near-white canvas gradient (top → bottom).
    static let canvasTop = Color(red: 0xF6/255, green: 0xF8/255, blue: 0xFB/255)
    static let canvasBottom = Color(red: 0xED/255, green: 0xF0/255, blue: 0xF5/255)
    /// Legacy alias some views still reference for scrims.
    static let backgroundBottom = canvasBottom
    static let background = Color.appBackground

    /// 20pt matches the system large-title leading inset so body and nav title
    /// line up on the left edge.
    static let screenPadding: CGFloat = AppSpacing.xl
}
