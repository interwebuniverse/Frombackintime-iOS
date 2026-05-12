//
//  NetworkClientFactory.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum NetworkClientFactory {
    static func make(
        environment: AppEnvironment = .current,
        mockRegistry: MockDataRegistry? = nil,
        mockDatabase: MockDatabase? = nil
    ) -> NetworkClientType {
        switch environment {
        case .live:
            return NetworkClient(session: .shared)
        case .mock:
            let registry = mockRegistry ?? Self.defaultMockRegistry()
            let database = mockDatabase ?? MockDatabase()
            return MockNetworkClient(provider: registry, database: database)
        }
    }

    static func defaultMockRegistry() -> MockDataRegistry {
        let registry = MockDataRegistry()
        registry.register(ExampleMockDataProvider())
        // Register one provider per feature here.
        return registry
    }
}
