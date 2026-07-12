//
//  View+A11y.swift
//  FromBackInTime
//
//  Stable identifiers for UI-test automation (Maestro / XCUITest). Kept
//  separate from `.accessibilityLabel`, which is VoiceOver copy that changes
//  with wording: test IDs must stay put even when the user-facing text is
//  reworded, so flows don't go red on a copy tweak. IDs use a
//  `screen.control` convention, e.g. "home.screen", "record.button".
//

import SwiftUI

extension View {
    /// Attach a stable automation identifier used by the Maestro UI suite.
    func a11y(_ id: String) -> some View {
        accessibilityIdentifier(id)
    }
}
