//
//  NetworkClient+Validate.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension Notification.Name {
    /// Posted when the session is truly over (401 and the refresh token could
    /// not mint a new session). Listeners re-establish an anonymous session.
    static let unauthorizedAccess = Notification.Name("unauthorizedAccess")
}

extension NetworkClient {
    /// Throws on any non-2xx status. 4xx responses carrying the backend error
    /// envelope `{ error: { code, message } }` throw NetworkErrorModel so the
    /// user sees the backend's actual message ("Delivery date must be in the
    /// future", "Sign in with Apple or Google to schedule delivery", ...).
    func validate(response: URLResponse, data: Data? = nil) async throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401:
            throw NetworkError.unauthorized
        case 402:
            // Surface the backend's specific paywall message when it sent one
            // ("Active subscription required"), not a canned string.
            if let data, let model = try? JSONDecoder().decode(NetworkErrorModel.self, from: data) {
                throw model
            }
            throw NetworkError.payment
        case 400..<500:
            if let data, let model = try? JSONDecoder().decode(NetworkErrorModel.self, from: data) {
                throw model
            }
            throw httpResponse.statusCode == 409 ? NetworkError.conflict : NetworkError.clientError
        case 500...:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknown
        }
    }

    func validate<T: Decodable>(
        response: URLResponse,
        request: Request,
        data: Data,
        client: NetworkClientType
    ) async throws -> T {
        try await validate(response: response, data: data)
        return try decode(and: data)
    }
}
