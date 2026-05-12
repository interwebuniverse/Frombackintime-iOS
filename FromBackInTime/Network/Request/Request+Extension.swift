//
//  Request+Extension.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension Request {
    var fullPath: String? { return nil }
    var method: RequestMethod { return .GET }
    var httpBody: Encodable? { return nil }
    var queries: [String: String]? { return nil }
    var headers: [String: String] {
        var headers = [
            "Accept": "*/*",
            "Content-Type": "application/json"
        ]
        if needAuth {
            @Keychain(key: .accesstoken) var accesstoken
            headers["Authorization"] = "Bearer \(accesstoken ?? "")"
        }
        return headers
    }
    var needAuth: Bool { return true }
}
