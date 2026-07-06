//
//  RecipientRequests.swift
//  FromBackInTime
//

import Foundation

enum RecipientRequests {
    struct List: Request {
        var path: String { "/v1/recipients" }
    }

    struct Create: Request {
        let body: Body
        var path: String { "/v1/recipients" }
        var method: RequestMethod { .POST }
        var httpBody: Encodable? { body }

        struct Body: Encodable {
            let name: String
            let relationship: String?
            let email: String
            let hue: Double?
        }
    }

    struct Update: Request {
        let id: String
        let body: Body
        var path: String { "/v1/recipients/\(id)" }
        var method: RequestMethod { .PATCH }
        var httpBody: Encodable? { body }

        struct Body: Encodable {
            let name: String?
            let relationship: String?
            let email: String?
            let hue: Double?
        }
    }

    struct Delete: Request {
        let id: String
        var path: String { "/v1/recipients/\(id)" }
        var method: RequestMethod { .DELETE }
    }
}
