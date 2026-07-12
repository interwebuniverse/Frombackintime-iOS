//
//  AuthState.swift
//  FromBackInTime
//

import Foundation

struct AuthState {
    var isAuthenticated = false
    var isAnonymous = false
    var userId: String? = nil
    var email: String? = nil
    /// Display name from the backend profile (/v1/me), set during onboarding.
    var profileName: String? = nil
    var isLoading = false
    var error: String? = nil
    /// Set when a real (signed-in) session ended unexpectedly and we fell back
    /// to anonymous. Drives a "sign in again" prompt so the vault doesn't just
    /// appear to vanish.
    var sessionExpired = false
}
