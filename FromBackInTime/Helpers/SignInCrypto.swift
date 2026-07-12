//
//  SignInCrypto.swift
//  FromBackInTime
//
//  Small crypto helpers for native sign-in flows. Apple wants the SHA-256 of
//  the nonce as hex inside the ASAuthorization request while Supabase gets
//  the raw nonce; PKCE wants the SHA-256 of the verifier as base64url.
//

import CryptoKit
import Foundation
import Security

enum SignInCrypto {
    /// URL-safe random string, used as the Apple nonce and the PKCE verifier.
    static func randomURLSafe(byteCount: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        // A silent RNG failure would hand back an all-zero, fully predictable
        // nonce / PKCE verifier and quietly defeat the login's replay protection.
        // Crash loudly instead; this only fails if the system CSPRNG is broken.
        precondition(status == errSecSuccess, "SecRandomCopyBytes failed: \(status)")
        return Data(bytes).base64URLEncoded
    }

    /// Hex SHA-256, the format ASAuthorizationAppleIDRequest.nonce expects.
    static func sha256Hex(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    /// Base64url SHA-256, the format the PKCE code_challenge expects.
    static func pkceChallenge(for verifier: String) -> String {
        Data(SHA256.hash(data: Data(verifier.utf8))).base64URLEncoded
    }
}

private extension Data {
    var base64URLEncoded: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
