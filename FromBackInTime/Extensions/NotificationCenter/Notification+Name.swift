//
//  Notification+Name.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension Notification.Name {
    static let test = Notification.Name("test")

    /// Posted whenever the signed-in identity changes (anonymous sign-in after
    /// session loss, Apple/Google sign-in, sign-out). Listeners reload
    /// user-scoped data so no screen keeps showing the previous user's vault.
    static let sessionReplaced = Notification.Name("sessionReplaced")
}
