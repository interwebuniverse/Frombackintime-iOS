//
//  NetworkErrorModel.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

/// Backend error envelope: `{ error: { code, message } }`. Also accepts a
/// flat `{ message }` so non-enveloped sources still decode.
struct NetworkErrorModel: Error, Decodable {
    let code: String?
    let message: String

    private struct Inner: Decodable {
        let code: String?
        let message: String
    }

    private enum CodingKeys: String, CodingKey {
        case error, message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let inner = try container.decodeIfPresent(Inner.self, forKey: .error) {
            code = inner.code
            message = inner.message
        } else {
            code = nil
            message = try container.decode(String.self, forKey: .message)
        }
    }
}

extension NetworkErrorModel: LocalizedError {
    var errorDescription: String? { message }
}

extension Error {
    var asNetworkErrorModel: NetworkErrorModel? {
        return self as? NetworkErrorModel
    }
}
