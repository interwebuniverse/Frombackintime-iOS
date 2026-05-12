//
//  ExampleStoreUI+Item.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension ExampleStoreUI.Item {
    init(from response: ExampleResponses.Item) {
        self.init(
            id: response.id ?? UUID().uuidString,
            title: response.title ?? "",
            subtitle: response.subtitle ?? ""
        )
    }
}
