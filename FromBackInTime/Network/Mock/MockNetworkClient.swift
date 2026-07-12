//
//  MockNetworkClient.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

final class MockNetworkClient: NetworkClientType {
    let session: URLSession
    private let provider: MockDataProvider
    private let database: MockDatabase
    private let simulatedDelay: UInt64

    init(
        provider: MockDataProvider,
        database: MockDatabase,
        simulatedDelay: UInt64 = 300_000_000
    ) {
        self.session = .shared
        self.provider = provider
        self.database = database
        self.simulatedDelay = simulatedDelay
    }

    func request<T: Decodable>(_ request: Request) async throws -> T {
        try await Task.sleep(nanoseconds: simulatedDelay)

        guard let data = provider.response(for: request, database: database) else {
            throw NetworkError.badResponse
        }

        logMock(request: request, responseData: data)
        return try decode(and: data)
    }

    func requestData(from url: URL) async throws -> Data {
        try await Task.sleep(nanoseconds: simulatedDelay)
        return Data()
    }

    func uploadMultipart<T: Decodable>(request: MultipartRequest) async throws -> T {
        try await Task.sleep(nanoseconds: simulatedDelay)
        throw NetworkError.badResponse
    }

    func upload(_ data: Data, with request: Request) async throws {
        try await Task.sleep(nanoseconds: simulatedDelay)
        let responseData = provider.response(for: request, database: database)
        logMock(request: request, responseData: responseData)
    }

    func validate(response: URLResponse, data: Data?) async throws {
        // No-op for mocks.
    }

    func decode<T: Decodable>(
        with type: T.Type = T.self,
        and data: Data
    ) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }

    private func logMock(request: Request, responseData: Data?) {
        let urlRequest = try? request.urlRequest()
        NetworkLogger.log(request: urlRequest, data: responseData, response: nil)
    }
}
