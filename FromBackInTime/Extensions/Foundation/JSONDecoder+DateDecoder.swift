//
//  JSONDecoder+DateDecoder.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension JSONDecoder {
    static var dateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]
            
            guard let date = formatter.date(from: dateString) else {
                throw NetworkError.dateDecoding
            }
            
            return date
        }
        return decoder
    }
}
