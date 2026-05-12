//
//  ExampleRepository.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

protocol ExampleRepositoryType {
    func listItems() async throws -> ExampleResponses.ItemList
    func itemDetail(id: String) async throws -> ExampleResponses.Item
}

final class ExampleRepository: ExampleRepositoryType {
    private let client: NetworkClientType

    init(client: NetworkClientType) {
        self.client = client
    }

    func listItems() async throws -> ExampleResponses.ItemList {
        try await client.request(ExampleRequests.ListItems())
    }

    func itemDetail(id: String) async throws -> ExampleResponses.Item {
        try await client.request(ExampleRequests.ItemDetail(id: id))
    }
}
