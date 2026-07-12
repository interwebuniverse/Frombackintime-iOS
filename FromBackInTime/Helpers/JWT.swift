//
//  JWT.swift
//  FromBackInTime
//
//  Minimal JWT payload reader. The Supabase access token carries the claims
//  the app needs to restore auth state on cold launch (is_anonymous, sub,
//  email) without a network call. No signature verification: the backend
//  verifies; this is only for locally restoring UI state.
//

import Foundation

enum JWT {
    static func payload(of token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }

        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return json as? [String: Any]
    }
}
