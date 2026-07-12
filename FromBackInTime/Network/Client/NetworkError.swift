//
//  NetworkError.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case urlParsing
    case badResponse
    case unauthorized
    case clientError
    case serverError
    case dateDecoding
    case payment
    case conflict
    case unknown

    // LocalizedError: makes `error.localizedDescription` show these strings
    // even through an `any Error` (the default otherwise is Foundation's
    // generic "operation couldn't be completed").
    var errorDescription: String? { localizedDescription }

    var localizedDescription: String {
        switch self {
        case .urlParsing:
            return "Failed to parse the URL."
        case .badResponse:
            return "Received an invalid response from the server."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .clientError:
            return "A client-side error occurred. Please try again."
        case .serverError:
            return "A server-side error occurred. Please try again later."
        case .dateDecoding:
            return "Failed to decode a date from the response."
        case .payment:
            return "This content is behind a paywall. Please subscribe to continue."
        case .conflict:
            return "The request conflicts with the current state. Please refresh and try again."
        case .unknown:
            return "An unknown error occurred."
        }
    }

    /// Errors the app treats as "session ended - navigate the user out" rather
    /// than surfacing to the current screen.
    var isSessionEnded: Bool {
        self == .unauthorized
    }
}

extension Error {
    var isSessionEnded: Bool {
        (self as? NetworkError)?.isSessionEnded ?? false
    }
}
