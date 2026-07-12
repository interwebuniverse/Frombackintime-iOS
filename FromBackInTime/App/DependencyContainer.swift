//
//  DependencyContainer.swift
//  FromBackInTime
//
//  DI: owns the network client + every repository, and builds the global stores.
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
    @ObservationIgnored let authRepository: AuthRepositoryType
    @ObservationIgnored let recipientRepository: RecipientRepositoryType
    @ObservationIgnored let messageRepository: MessageRepositoryType
    @ObservationIgnored let ctmRepository: CTMRepositoryType
    @ObservationIgnored let meRepository: MeRepositoryType

    init(environment: AppEnvironment = .current) {
        self.environment = environment
        let client = NetworkClientFactory.make(environment: environment)
        self.networkClient = client

        self.exampleRepository = ExampleRepository(client: client)
        self.authRepository = AuthRepository(client: client)
        self.recipientRepository = RecipientRepository(client: client)
        self.messageRepository = MessageRepository(client: client)
        self.ctmRepository = CTMRepository(client: client)
        self.meRepository = MeRepository(client: client)
    }

    // MARK: - Store factories

    func makeExampleStore() -> ExampleStore {
        ExampleStore(repository: exampleRepository)
    }

    func makeAuthStore() -> AuthStore {
        AuthStore(repository: authRepository, meRepository: meRepository)
    }

    func makeAppStore() -> MockAppStore {
        MockAppStore(
            recipientRepository: recipientRepository,
            messageRepository: messageRepository,
            ctmRepository: ctmRepository,
            environment: environment
        )
    }
}
