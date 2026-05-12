//
//  NetworkClient+Decode.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension NetworkClient {
    func decode<T: Decodable>(
        with type: T.Type = T.self,
        and data: Data
    ) throws -> T {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print(
                "🛠️ Failed to decode response! 🔍 Error details: \(error.decodingMessage)"
            )
            throw error
        }
    }
}
