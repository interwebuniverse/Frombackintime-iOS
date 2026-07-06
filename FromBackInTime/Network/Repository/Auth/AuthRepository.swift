//
//  AuthRepository.swift
//  FromBackInTime
//

import Foundation

protocol AuthRepositoryType {
    func signInAnonymously() async throws -> AuthResponses.Session
    func signInWithApple(idToken: String, nonce: String?) async throws -> AuthResponses.Session
    func refresh(refreshToken: String) async throws -> AuthResponses.Session
}

final class AuthRepository: AuthRepositoryType {
    private let client: NetworkClientType

    init(client: NetworkClientType) {
        self.client = client
    }

    func signInAnonymously() async throws -> AuthResponses.Session {
        try await client.request(AuthRequests.SignInAnonymously())
    }

    func signInWithApple(idToken: String, nonce: String?) async throws -> AuthResponses.Session {
        try await client.request(AuthRequests.SignInWithApple(idToken: idToken, nonce: nonce))
    }

    func refresh(refreshToken: String) async throws -> AuthResponses.Session {
        try await client.request(AuthRequests.RefreshToken(refreshToken: refreshToken))
    }
}
