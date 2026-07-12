//
//  SessionRefresher.swift
//  FromBackInTime
//
//  Exchanges the stored refresh token for a fresh Supabase session when a
//  request 401s. Supabase rotates refresh tokens (single use), so concurrent
//  401s must share one in-flight refresh instead of racing each other.
//

import Foundation

actor SessionRefresher {
    static let shared = SessionRefresher()

    private var inFlight: Task<Void, Error>?

    /// Refresh the session or throw. On an unrecoverable failure the stored
    /// session is cleared and `.unauthorizedAccess` is posted so the app can
    /// fall back to a fresh anonymous session.
    func refresh(using client: NetworkClientType) async throws {
        if let inFlight {
            return try await inFlight.value
        }
        let task = Task {
            guard let token = SessionStore.refreshToken, !token.isEmpty else {
                await Self.sessionEnded()
                throw NetworkError.unauthorized
            }
            do {
                let session: AuthResponses.Session = try await client.request(
                    AuthRequests.RefreshToken(refreshToken: token)
                )
                guard let access = session.accessToken, !access.isEmpty else {
                    throw NetworkError.unauthorized
                }
                SessionStore.accessToken = access
                if let refresh = session.refreshToken, !refresh.isEmpty {
                    SessionStore.refreshToken = refresh
                }
            } catch {
                await Self.sessionEnded()
                throw NetworkError.unauthorized
            }
        }
        inFlight = task
        defer { inFlight = nil }
        try await task.value
    }

    @MainActor
    private static func sessionEnded() {
        SessionStore.clear()
        NotificationCenter.default.post(name: .unauthorizedAccess, object: nil)
    }
}
