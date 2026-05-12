//
//  NetworkClient+Validate.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension Notification.Name {
    static let unauthorizedAccess = Notification.Name("unauthorizedAccess")
    static let deviceInvalidated = Notification.Name("deviceInvalidated")
}

extension NetworkClient {
    private func handleUnauthorized() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .unauthorizedAccess, object: nil)
        }
    }

    private func handleDeviceInvalidated() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .deviceInvalidated, object: nil)
        }
    }

    func validate(response: URLResponse) async throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401:
            handleUnauthorized()
            throw NetworkError.unauthorized
        case 403:
            handleDeviceInvalidated()
            throw NetworkError.deviceInvalidated
        case 402:
            throw NetworkError.payment
        case 409:
            throw NetworkError.conflict
        case 400..<500:
            throw NetworkError.clientError
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
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return try decode(and: data)
        case 401:
            handleUnauthorized()
            throw NetworkError.unauthorized
        case 403:
            handleDeviceInvalidated()
            throw NetworkError.deviceInvalidated
        case 402:
            throw NetworkError.payment
        case 409:
            throw NetworkError.conflict
        case 400..<500:
            let error = try? JSONDecoder().decode(NetworkErrorModel.self, from: data)
            throw error ?? NetworkError.clientError
        case 500...:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknown
        }
    }
}
