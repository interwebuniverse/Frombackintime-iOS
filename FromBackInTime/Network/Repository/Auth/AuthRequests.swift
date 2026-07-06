//
//  AuthRequests.swift
//  FromBackInTime
//
//  Supabase GoTrue REST. These hit Supabase directly via `fullPath`, carry the
//  publishable key in `apikey` (not the stored Bearer token, so `needAuth =
//  false`), because we are minting the token here. The grant type is baked into
//  the fullPath query since the URL builder ignores `queries` when `fullPath`
//  is set.
//

import Foundation

enum AuthRequests {
    // Anonymous sign-in: POST /signup with an empty body. Requires "Anonymous
    // sign-ins" enabled in the Supabase dashboard. Returns a full session.
    struct SignInAnonymously: Request {
        var fullPath: String? { "\(SupabaseConfig.authBaseURL)/signup" }
        var path: String { "" }
        var method: RequestMethod { .POST }
        var needAuth: Bool { false }
        var headers: [String: String] { SupabaseConfig.authHeaders }
        var httpBody: Encodable? { Body() }

        struct Body: Encodable {
            let data = Empty()
            let gotrue_meta_security = Empty()
            struct Empty: Encodable {}
        }
    }

    // Exchange a refresh token for a fresh access token.
    struct RefreshToken: Request {
        let refreshToken: String
        var fullPath: String? { "\(SupabaseConfig.authBaseURL)/token?grant_type=refresh_token" }
        var path: String { "" }
        var method: RequestMethod { .POST }
        var needAuth: Bool { false }
        var headers: [String: String] { SupabaseConfig.authHeaders }
        var httpBody: Encodable? { Body(refresh_token: refreshToken) }

        struct Body: Encodable { let refresh_token: String }
    }

    // Sign in with an Apple identity token (grant_type=id_token). Produces a
    // non-anonymous session, which the backend requires before anything sends.
    struct SignInWithApple: Request {
        let idToken: String
        let nonce: String?
        var fullPath: String? { "\(SupabaseConfig.authBaseURL)/token?grant_type=id_token" }
        var path: String { "" }
        var method: RequestMethod { .POST }
        var needAuth: Bool { false }
        var headers: [String: String] { SupabaseConfig.authHeaders }
        var httpBody: Encodable? { Body(provider: "apple", id_token: idToken, nonce: nonce) }

        struct Body: Encodable {
            let provider: String
            let id_token: String
            let nonce: String?
        }
    }
}
