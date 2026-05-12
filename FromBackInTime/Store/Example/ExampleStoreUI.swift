//
//  ExampleStoreUI.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum ExampleStoreUI {
    struct Item: Equatable, Hashable, Identifiable {
        let id: String
        let title: String
        let subtitle: String
    }
}
