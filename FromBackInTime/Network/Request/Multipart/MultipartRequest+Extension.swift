//
//  MultipartRequest+Extension.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension MultipartRequest {
    var method: RequestMethod { .POST }
    var httpBody: (any Encodable)? { return nil }
    var headers: [String: String] {
        var headers = [
            "Accept": "*/*"
        ]
        if needAuth {
            @Keychain(key: .accesstoken) var accesstoken
            headers["Authorization"] = "Bearer \(accesstoken ?? "")"
        }
        return headers
    }
}
