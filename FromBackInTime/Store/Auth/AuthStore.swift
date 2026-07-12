//
//  AuthStore.swift
//  FromBackInTime
//
//  Global, long-lived auth store. Owns the session lifecycle: on launch it makes
//  sure a session exists (anonymous, so the onboarding-first user can browse and
//  draft immediately), and upgrades to a real Apple/Google sign-in when the user
//  needs to actually send. Tokens live in the Keychain via SessionStore; the
//  Request layer reads them automatically. Also owns the backend profile
//  (/v1/me): display name and onboarding preferences.
//

import Foundation

@MainActor
@Observable
final class AuthStore {
    private let repository: AuthRepositoryType
    private let meRepository: MeRepositoryType
    var state = AuthState()

    init(repository: AuthRepositoryType, meRepository: MeRepositoryType) {
        self.repository = repository
        self.meRepository = meRepository
        restoreFromStoredSession()

        // The network layer posts this when a 401 could not be recovered by a
        // token refresh. Self-heal into a fresh anonymous session so the app
        // keeps working; a real user can sign back in from Settings.
        NotificationCenter.default.addObserver(
            forName: .unauthorizedAccess, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in await self?.sessionEnded() }
        }
    }

#if MOCK
    // The Mock scheme runs as a signed-in test user so every create / edit / CTM
    // / add-person flow is exercisable (and demoable) without a real Apple or
    // Google sign-in. Applied at every session entry point below. Live builds are
    // unaffected (start anonymous, upgrade on real sign-in).
    private func applyMockSession() {
        state.isAuthenticated = true
        state.isAnonymous = false
        state.userId = "mock-user"
        state.email = "you@frombackintime.app"
        state.sessionExpired = false
    }
#endif

    // Guarantee a usable session before the app makes authed calls.
    func ensureSession() async {
        #if MOCK
        applyMockSession()
        #else
        if SessionStore.isSignedIn {
            restoreFromStoredSession()
            return
        }
        await signInAnonymously()
        #endif
    }

    func signInAnonymously() async {
        #if MOCK
        applyMockSession()
        #else
        await run { try await self.repository.signInAnonymously() }
        #endif
    }

    func signInWithApple(idToken: String, nonce: String?) async {
        await run { try await self.repository.signInWithApple(idToken: idToken, nonce: nonce) }
        if state.isAuthenticated, !state.isAnonymous {
            NotificationCenter.default.post(name: .sessionReplaced, object: nil)
        }
    }

    // Google runs through Supabase's hosted OAuth in a web auth session, then
    // exchanges the PKCE code. A user closing the sheet is not an error.
    func signInWithGoogle() async {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }
        do {
            let (code, verifier) = try await GoogleAuthSession().start()
            persist(try await repository.exchangeCode(authCode: code, codeVerifier: verifier))
            if state.isAuthenticated, !state.isAnonymous {
                NotificationCenter.default.post(name: .sessionReplaced, object: nil)
            }
        } catch {
            guard !GoogleAuthSession.isUserCancel(error) else { return }
            state.error = error.localizedDescription
        }
    }

    /// Sign out and immediately mint a fresh anonymous session so the app
    /// never runs without a token.
    func signOut() async {
        SessionStore.clear()
        state = AuthState()
        await signInAnonymously()
        NotificationCenter.default.post(name: .sessionReplaced, object: nil)
    }

    // MARK: - Profile (/v1/me)

    func loadProfile() async {
        guard let profile = try? await meRepository.profile() else { return }
        state.profileName = profile.name
    }

    /// Push profile fields to the backend. Anonymous users have an app row
    /// too, so this works before sign-in; on upgrade at the onboarding auth
    /// gate the row carries over. Failures are non-fatal (retried next save).
    func updateProfile(name: String? = nil, notifPrefs: [String: Bool]? = nil) async {
        let timezone = TimeZone.current.identifier
        guard let profile = try? await meRepository.update(
            name: name, timezone: timezone, notifPrefs: notifPrefs
        ) else { return }
        state.profileName = profile.name
    }

    // MARK: - Session plumbing

    private func sessionEnded() async {
        // Remember whether a *real* account just dropped: if so, we prompt the
        // user to sign back in instead of silently swapping their vault for an
        // empty anonymous one (which reads as data loss).
        let wasSignedIn = state.isAuthenticated && !state.isAnonymous
        state = AuthState()
        await signInAnonymously()
        if wasSignedIn { state.sessionExpired = true }
        NotificationCenter.default.post(name: .sessionReplaced, object: nil)
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

    /// Rebuild auth state from the stored access token's claims, so a cold
    /// launch knows whether the session is anonymous without a network call.
    private func restoreFromStoredSession() {
        #if MOCK
        applyMockSession()
        return
        #endif
        guard let token = SessionStore.accessToken, !token.isEmpty else { return }
        state.isAuthenticated = true
        guard let claims = JWT.payload(of: token) else { return }
        state.isAnonymous = claims["is_anonymous"] as? Bool ?? false
        state.userId = claims["sub"] as? String
        state.email = claims["email"] as? String
    }
}
