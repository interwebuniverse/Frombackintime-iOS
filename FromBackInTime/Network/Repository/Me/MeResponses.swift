//
//  MeResponses.swift
//  FromBackInTime
//

import Foundation

enum MeResponses {
    struct Profile: Codable {
        var id: String?
        var email: String?
        var name: String?
        var timezone: String?
        var notifPrefs: [String: Bool]?
        var createdAt: String?
    }
}
