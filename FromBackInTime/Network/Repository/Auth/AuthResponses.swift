//
//  AuthResponses.swift
//  FromBackInTime
//
//  Supabase GoTrue session shape. NOT wrapped in our `{ data }` envelope, this
//  is Supabase's own response, so repositories decode it directly.
//

import Foundation

enum AuthResponses {
    struct Session: Codable {
        var accessToken: String?
        var refreshToken: String?
        var expiresAt: Int?
        var user: User?

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case expiresAt = "expires_at"
            case user
        }
    }

    struct User: Codable {
        var id: String?
        var email: String?
        var isAnonymous: Bool?

        enum CodingKeys: String, CodingKey {
            case id, email
            case isAnonymous = "is_anonymous"
        }
    }
}
