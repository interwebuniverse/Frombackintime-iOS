//
//  DependencyContainer.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class DependencyContainer {
    @ObservationIgnored let environment: AppEnvironment
    @ObservationIgnored let networkClient: NetworkClientType

    // MARK: - Repositories

    @ObservationIgnored let exampleRepository: ExampleRepositoryType

    init(environment: AppEnvironment = .current) {
        self.environment = environment
        self.networkClient = NetworkClientFactory.make(environment: environment)

        self.exampleRepository = ExampleRepository(client: networkClient)
    }

    // MARK: - Store factories

    func makeExampleStore() -> ExampleStore {
        ExampleStore(repository: exampleRepository)
    }
}
