//
//  ExampleView.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

struct ExampleView: View {
    @Bindable var store: ExampleStore

    var body: some View {
        Group {
            if store.state.isLoading && store.state.items.isEmpty {
                ProgressView()
            } else if let error = store.state.error {
                VStack(spacing: 12) {
                    Text(error)
                        .appFont(.bodyS)
                        .multilineTextAlignment(.center)
                    Button(L10n.exampleRetry.localized) {
                        Task { await store.loadItems() }
                    }
                    .textButton()
                }
                .padding()
            } else {
                List(store.state.items) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).appFont(.heading6)
                        if !item.subtitle.isEmpty {
                            Text(item.subtitle)
                                .appFont(.bodyXS)
                                .foregroundStyle(Color.appSecondary)
                        }
                    }
                }
                .refreshable { await store.loadItems() }
            }
        }
        .navigationTitle(L10n.exampleTitle.localized)
        .task { await store.loadItems() }
    }
}

#Preview {
    PreviewContainer {
        ExampleView(store: ExampleStore(
            repository: ExampleRepository(
                client: NetworkClientFactory.make(environment: .mock)
            )
        ))
    }
}
