//
//  GoogleAuthSession.swift
//  FromBackInTime
//
//  Google sign-in through Supabase's hosted OAuth (PKCE) inside an
//  ASWebAuthenticationSession. No Google SDK: Supabase holds the Google
//  client credentials, the app only needs the custom URL scheme callback.
//  Returns the auth code + verifier; the repository exchanges them for a
//  session at token?grant_type=pkce.
//

import AuthenticationServices
import UIKit

@MainActor
final class GoogleAuthSession: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let callbackScheme = "frombackintime"

    private var session: ASWebAuthenticationSession?

    func start() async throws -> (code: String, verifier: String) {
        let verifier = SignInCrypto.randomURLSafe()

        var components = URLComponents(string: "\(SupabaseConfig.authBaseURL)/authorize")!
        components.queryItems = [
            URLQueryItem(name: "provider", value: "google"),
            URLQueryItem(name: "redirect_to", value: "\(Self.callbackScheme)://auth-callback"),
            URLQueryItem(name: "code_challenge", value: SignInCrypto.pkceChallenge(for: verifier)),
            URLQueryItem(name: "code_challenge_method", value: "s256")
        ]

        let callback: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: components.url!,
                callbackURLScheme: Self.callbackScheme
            ) { url, error in
                if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: error ?? URLError(.userCancelledAuthentication))
                }
            }
            session.presentationContextProvider = self
            self.session = session
            session.start()
        }

        guard let code = URLComponents(url: callback, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value else {
            throw URLError(.badServerResponse)
        }
        return (code, verifier)
    }

    static func isUserCancel(_ error: Error) -> Bool {
        if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin { return true }
        if let urlError = error as? URLError, urlError.code == .userCancelledAuthentication { return true }
        return false
    }

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.firstKeyWindow ?? ASPresentationAnchor()
        }
    }
}
