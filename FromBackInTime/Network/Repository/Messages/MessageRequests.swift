//
//  MessageRequests.swift
//  FromBackInTime
//

import Foundation

enum MessageRequests {
    struct List: Request {
        let kind: String?
        var path: String { "/v1/messages" }
        var queries: [String: String]? { kind.map { ["kind": $0] } }
    }

    struct Detail: Request {
        let id: String
        var path: String { "/v1/messages/\(id)" }
    }

    struct Create: Request {
        let body: Body
        var path: String { "/v1/messages" }
        var method: RequestMethod { .POST }
        var httpBody: Encodable? { body }

        struct Body: Encodable {
            let recipientId: String
            let kind: String
            let medium: String
            let occasion: String?
            let bodyText: String?
            let durationSeconds: Int?
            let deliverAt: String?
        }
    }

    struct RequestUploadURL: Request {
        let id: String
        let contentType: String
        var path: String { "/v1/messages/\(id)/upload-url" }
        var method: RequestMethod { .POST }
        var httpBody: Encodable? { Body(contentType: contentType) }

        struct Body: Encodable { let contentType: String }
    }

    struct Finalize: Request {
        let id: String
        var path: String { "/v1/messages/\(id)/finalize" }
        var method: RequestMethod { .POST }
    }

    struct Patch: Request {
        let id: String
        let body: Body
        var path: String { "/v1/messages/\(id)" }
        var method: RequestMethod { .PATCH }
        var httpBody: Encodable? { body }

        struct Body: Encodable {
            let occasion: String?
            let recipientId: String?
            let deliverAt: String?
        }
    }

    struct Delete: Request {
        let id: String
        var path: String { "/v1/messages/\(id)" }
        var method: RequestMethod { .DELETE }
    }

    // Direct-to-R2 upload via the presigned PUT URL. `fullPath` is the presigned
    // URL (its signature lives in the query string), so no auth header and no
    // apikey. Content-Type must match what the backend signed.
    struct UploadToR2: Request {
        let url: String
        let contentType: String
        var fullPath: String? { url }
        var path: String { "" }
        var method: RequestMethod { .PUT }
        var needAuth: Bool { false }
        var headers: [String: String] { ["Content-Type": contentType] }
    }
}
