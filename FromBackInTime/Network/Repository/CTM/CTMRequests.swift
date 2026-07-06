//
//  CTMRequests.swift
//  FromBackInTime
//

import Foundation

enum CTMRequests {
    // Arm a CTM message. Optional cadence overrides; backend defaults to 30-day
    // check-ins and a 3-miss release threshold.
    struct Activate: Request {
        let messageId: String
        let body: Body
        var path: String { "/v1/messages/\(messageId)/ctm/activate" }
        var method: RequestMethod { .POST }
        var httpBody: Encodable? { body }

        struct Body: Encodable {
            let checkinIntervalDays: Int?
            let releaseThreshold: Int?
        }
    }

    // "I'm alive" - resets every armed switch the user owns.
    struct CheckIn: Request {
        var path: String { "/v1/ctm/check-in" }
        var method: RequestMethod { .POST }
    }

    struct Snooze: Request {
        var path: String { "/v1/ctm/snooze" }
        var method: RequestMethod { .POST }
    }
}
