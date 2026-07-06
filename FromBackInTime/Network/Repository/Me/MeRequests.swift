//
//  MeRequests.swift
//  FromBackInTime
//

import Foundation

enum MeRequests {
    struct Get: Request {
        var path: String { "/v1/me" }
    }

    struct Update: Request {
        let body: Body
        var path: String { "/v1/me" }
        var method: RequestMethod { .PATCH }
        var httpBody: Encodable? { body }

        struct Body: Encodable {
            let name: String?
            let timezone: String?
        }
    }

    struct Delete: Request {
        var path: String { "/v1/me" }
        var method: RequestMethod { .DELETE }
    }
}
