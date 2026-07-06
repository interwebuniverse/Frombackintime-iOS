//
//  MessageResponses.swift
//  FromBackInTime
//

import Foundation

enum MessageResponses {
    struct Message: Codable, Hashable {
        var id: String?
        var recipientId: String?
        var kind: String?
        var medium: String?
        var occasion: String?
        var hasBody: Bool?
        var durationSeconds: Int?
        var mediaStatus: String?
        var mediaContentType: String?
        var status: String?
        var deliverAt: String?
        var createdAt: String?
        // Present only on the single-message detail response.
        var bodyText: String?
    }

    struct UploadURL: Codable {
        var uploadUrl: String?
        var key: String?
        var expiresIn: Int?
    }
}
