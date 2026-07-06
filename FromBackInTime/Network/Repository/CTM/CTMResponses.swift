//
//  CTMResponses.swift
//  FromBackInTime
//

import Foundation

enum CTMResponses {
    // Returned once when a switch is armed. `accessCode` is shown to the owner a
    // single time - they share it with the recipient out of band.
    struct Activation: Codable {
        var messageId: String?
        var status: String?
        var checkinIntervalDays: Int?
        var releaseThreshold: Int?
        var nextCheckinAt: String?
        var accessCode: String?
    }

    struct CheckIn: Codable { var reset: Int? }
    struct Snooze: Codable { var snoozed: Int? }
}
