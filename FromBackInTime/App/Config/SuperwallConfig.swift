//
//  SuperwallConfig.swift
//  FromBackInTime
//
//  Superwall project config. The API key is a publishable client key (safe to
//  ship in the app, like the Supabase anon key).
//
//  Dashboard setup required for the hard paywall to work:
//  1. Create a campaign in the Superwall dashboard.
//  2. Add the placement `gatePlacement` (below) as a trigger on that campaign.
//  3. Set the paywall to **Gated** so the app stays locked until the user
//     subscribes, and ideally non-dismissible (no close button) for a true
//     hard gate. If a user does dismiss it, the app re-presents it.
//

import Foundation

enum SuperwallConfig {
    /// Publishable Superwall API key (starts with `pk_...`). Replace this with
    /// the key from Superwall dashboard → Settings → Keys.
    static let apiKey = "pk_REPLACE_WITH_YOUR_SUPERWALL_PUBLISHABLE_KEY"

    /// The placement the hard paywall registers, fired at the end of onboarding
    /// and on every launch for a user who finished onboarding but isn't paying.
    /// Must match the placement/trigger on your Gated campaign.
    static let gatePlacement = "onboarding_complete"

    /// True once a real key has been set, so we can fail safe in debug.
    static var isConfigured: Bool { apiKey.hasPrefix("pk_") && !apiKey.contains("REPLACE") }
}
