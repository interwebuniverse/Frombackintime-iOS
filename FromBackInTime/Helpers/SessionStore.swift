//
//  SessionStore.swift
//  FromBackInTime
//
//  Keychain-backed access/refresh tokens. Uses KeychainSwift directly (the same
//  backend the @Keychain wrapper uses) rather than the wrapper, since a property
//  wrapper does not compose with the Observation macro and reads awkwardly inside
//  computed accessors. The Request layer reads the access token from the same
//  Keychain key, so writing it here authenticates every backend call.
//

import Foundation
import KeychainSwift

enum SessionStore {
    private static let keychain = KeychainSwift()

    static var accessToken: String? {
        get { keychain.get(KeychainKey.accesstoken.rawValue) }
        set { set(newValue, for: .accesstoken) }
    }

    static var refreshToken: String? {
        get { keychain.get(KeychainKey.refreshtoken.rawValue) }
        set { set(newValue, for: .refreshtoken) }
    }

    static var isSignedIn: Bool { !(accessToken ?? "").isEmpty }

    static func clear() {
        keychain.delete(KeychainKey.accesstoken.rawValue)
        keychain.delete(KeychainKey.refreshtoken.rawValue)
    }

    private static func set(_ value: String?, for key: KeychainKey) {
        if let value {
            keychain.set(value, forKey: key.rawValue)
        } else {
            keychain.delete(key.rawValue)
        }
    }
}
