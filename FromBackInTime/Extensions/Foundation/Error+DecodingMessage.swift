//
//  Error+DecodingMessage.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension Error {
    var decodingMessage: String {
        guard let decodingError = self as? DecodingError else {
            return "Error is not type of: DecodingError, its: \(self.localizedDescription)"
        }
        
        switch decodingError {
        case .dataCorrupted(let context):
            return "Data Corruption Error: The data could not be decoded due to corruption.\nDetails: \(context.debugDescription)\nCoding Path: \(context.codingPath)"
        case .keyNotFound(let key, let context):
            return "Key Not Found Error: The expected key '\(key)' was not found in the decoded data.\nDetails: \(context.debugDescription)\nCoding Path: \(context.codingPath)"
        case .valueNotFound(let value, let context):
            return "Value Not Found Error: The value for '\(value)' could not be found in the decoded data.\nDetails: \(context.debugDescription)\nCoding Path: \(context.codingPath)"
        case .typeMismatch(let type, let context):
            return "Type Mismatch Error: The expected type '\(type)' does not match the type of the value found during decoding.\nDetails: \(context.debugDescription)\nCoding Path: \(context.codingPath)"
        default:
            return "Unknown Decoding Error: An unexpected decoding error occurred.\nDetails: \(decodingError.localizedDescription)"
        }
    }
}
