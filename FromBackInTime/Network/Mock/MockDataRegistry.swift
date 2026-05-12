//
//  MockDataRegistry.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

final class MockDataRegistry: MockDataProvider {
    private var providers: [MockDataProvider] = []

    func register(_ provider: MockDataProvider) {
        providers.append(provider)
    }

    func response(for request: Request, database: MockDatabase) -> Data? {
        for provider in providers {
            if let data = provider.response(for: request, database: database) {
                return data
            }
        }
        return nil
    }
}
