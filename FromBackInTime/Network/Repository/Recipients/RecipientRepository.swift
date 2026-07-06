//
//  RecipientRepository.swift
//  FromBackInTime
//
//  Backend responses are wrapped in `{ data }`, so every call decodes
//  BaseResponse<T> and returns `.data`.
//

import Foundation

protocol RecipientRepositoryType {
    func list() async throws -> [RecipientResponses.Recipient]
    func create(name: String, relationship: String?, email: String, hue: Double?) async throws -> RecipientResponses.Recipient
    func update(id: String, name: String?, relationship: String?, email: String?, hue: Double?) async throws -> RecipientResponses.Recipient
    func delete(id: String) async throws
}

final class RecipientRepository: RecipientRepositoryType {
    private let client: NetworkClientType

    init(client: NetworkClientType) {
        self.client = client
    }

    func list() async throws -> [RecipientResponses.Recipient] {
        let res: BaseResponse<[RecipientResponses.Recipient]> = try await client.request(RecipientRequests.List())
        return res.data
    }

    func create(name: String, relationship: String?, email: String, hue: Double?) async throws -> RecipientResponses.Recipient {
        let body = RecipientRequests.Create.Body(name: name, relationship: relationship, email: email, hue: hue)
        let res: BaseResponse<RecipientResponses.Recipient> = try await client.request(RecipientRequests.Create(body: body))
        return res.data
    }

    func update(id: String, name: String?, relationship: String?, email: String?, hue: Double?) async throws -> RecipientResponses.Recipient {
        let body = RecipientRequests.Update.Body(name: name, relationship: relationship, email: email, hue: hue)
        let res: BaseResponse<RecipientResponses.Recipient> = try await client.request(RecipientRequests.Update(id: id, body: body))
        return res.data
    }

    func delete(id: String) async throws {
        let _: EmptyResponse = try await client.request(RecipientRequests.Delete(id: id))
    }
}
