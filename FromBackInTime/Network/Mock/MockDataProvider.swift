//
//  MockDataProvider.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

protocol MockDataProvider {
    func response(for request: Request, database: MockDatabase) -> Data?
}

extension MockDataProvider {
    func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }
}
