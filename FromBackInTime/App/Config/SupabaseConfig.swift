//
//  SupabaseConfig.swift
//  FromBackInTime
//
//  Supabase project config. The publishable (anon) key is a client-public key
//  by design, so it is safe to ship in the app. Same values across every
//  environment (one Supabase project). We only ever mint/verify tokens with
//  Supabase; our own backend then verifies that JWT.
//

import Foundation

enum SupabaseConfig {
    static let host = "jfnubrtuerbbehcteooo.supabase.co"
    static let anonKey = "sb_publishable_c3IdEICkMkyzg-BhGnSjKA_3aN9hySe"

    static var authBaseURL: String { "https://\(host)/auth/v1" }

    // Headers every GoTrue REST call needs: the publishable key as apikey plus a
    // Bearer of the same key, and JSON content type.
    static var authHeaders: [String: String] {
        [
            "apikey": anonKey,
            "Authorization": "Bearer \(anonKey)",
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
    }
}
