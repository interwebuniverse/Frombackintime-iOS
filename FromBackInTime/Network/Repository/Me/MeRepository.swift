//
//  MeRepository.swift
//  FromBackInTime
//

import Foundation

protocol MeRepositoryType {
    func profile() async throws -> MeResponses.Profile
    func update(name: String?, timezone: String?, notifPrefs: [String: Bool]?) async throws -> MeResponses.Profile
    func deleteAccount() async throws
}

final class MeRepository: MeRepositoryType {
    private let client: NetworkClientType

    init(client: NetworkClientType) {
        self.client = client
    }

    func profile() async throws -> MeResponses.Profile {
        let res: BaseResponse<MeResponses.Profile> = try await client.request(MeRequests.Get())
        return res.data
    }

    func update(name: String?, timezone: String?, notifPrefs: [String: Bool]?) async throws -> MeResponses.Profile {
        let body = MeRequests.Update.Body(name: name, timezone: timezone, notifPrefs: notifPrefs)
        let res: BaseResponse<MeResponses.Profile> = try await client.request(MeRequests.Update(body: body))
        return res.data
    }

    func deleteAccount() async throws {
        let _: EmptyResponse = try await client.request(MeRequests.Delete())
    }
}
