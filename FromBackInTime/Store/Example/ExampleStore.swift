//
//  ExampleStore.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

@MainActor
@Observable
final class ExampleStore {
    private let repository: ExampleRepositoryType

    var state = ExampleState()

    init(repository: ExampleRepositoryType) {
        self.repository = repository
    }

    func loadItems() async {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }

        do {
            let response = try await repository.listItems()
            state.items = (response.items ?? []).map(ExampleStoreUI.Item.init(from:))
        } catch {
            if !error.isSessionEnded {
                state.error = error.localizedDescription
            }
        }
    }
}
