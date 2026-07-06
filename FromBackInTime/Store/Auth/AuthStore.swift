//
//  AuthStore.swift
//  FromBackInTime
//
//  Global, long-lived auth store. Owns the session lifecycle: on launch it makes
//  sure a session exists (anonymous, so the onboarding-first user can browse and
//  draft immediately), and upgrades to a real Apple sign-in when the user needs
//  to actually send. Tokens live in the Keychain via SessionStore; the Request
//  layer reads them automatically.
//

import Foundation

@MainActor
@Observable
final class AuthStore {
    private let repository: AuthRepositoryType
    var state = AuthState()

    init(repository: AuthRepositoryType) {
        self.repository = repository
        state.isAuthenticated = SessionStore.isSignedIn
    }

    // Guarantee a usable session before the app makes authed calls.
    func ensureSession() async {
        if SessionStore.isSignedIn {
            state.isAuthenticated = true
            return
        }
        await signInAnonymously()
    }

    func signInAnonymously() async {
        await run { try await self.repository.signInAnonymously() }
    }

    func signInWithApple(idToken: String, nonce: String?) async {
        await run { try await self.repository.signInWithApple(idToken: idToken, nonce: nonce) }
    }

    func signOut() {
        SessionStore.clear()
        state = AuthState()
    }

    private func run(_ op: @escaping () async throws -> AuthResponses.Session) async {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }
        do {
            persist(try await op())
        } catch {
            state.error = error.localizedDescription
        }
    }

    private func persist(_ session: AuthResponses.Session) {
        SessionStore.accessToken = session.accessToken
        SessionStore.refreshToken = session.refreshToken
        state.isAuthenticated = (session.accessToken?.isEmpty == false)
        state.isAnonymous = session.user?.isAnonymous ?? false
        state.userId = session.user?.id
        state.email = session.user?.email
    }
}
