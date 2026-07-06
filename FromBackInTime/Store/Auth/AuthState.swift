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
    var isLoading = false
    var error: String? = nil
}
