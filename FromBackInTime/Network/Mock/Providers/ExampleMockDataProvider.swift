//
//  ExampleMockDataProvider.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

struct ExampleMockDataProvider: MockDataProvider {
    func response(for request: Request, database: MockDatabase) -> Data? {
        switch request {
        case is ExampleRequests.ListItems:
            let items = database.exampleItems.map {
                ExampleResponses.Item(id: $0.id, title: $0.title, subtitle: $0.subtitle)
            }
            return encode(ExampleResponses.ItemList(items: items))

        case let detail as ExampleRequests.ItemDetail:
            guard let hit = database.exampleItems.first(where: { $0.id == detail.id })
            else { return nil }
            return encode(
                ExampleResponses.Item(id: hit.id, title: hit.title, subtitle: hit.subtitle)
            )

        default:
            return nil
        }
    }
}
