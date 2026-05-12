//
//  Keychain.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import KeychainSwift

@propertyWrapper struct Keychain {
    let keychain = KeychainSwift()
    let key: KeychainKey
    
    var wrappedValue: String? {
        get { keychain.get(key.rawValue) }
        set {
            guard let newValue else { return }
            keychain.set(newValue, forKey: key.rawValue)
        }
    }
}
