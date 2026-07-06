//
//  RecipientResponses.swift
//  FromBackInTime
//

import Foundation

enum RecipientResponses {
    struct Recipient: Codable, Hashable {
        var id: String?
        var name: String?
        var relationship: String?
        var email: String?
        var emailStatus: String?
        var initials: String?
        var hue: Double?
        var createdAt: String?
    }
}
