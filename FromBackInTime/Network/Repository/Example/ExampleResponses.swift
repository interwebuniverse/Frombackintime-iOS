//
//  ExampleResponses.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum ExampleResponses {
    struct Item: Codable, Hashable {
        var id: String?
        var title: String?
        var subtitle: String?
    }

    struct ItemList: Codable, Hashable {
        var items: [Item]?
    }
}
