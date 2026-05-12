//
//  MockDatabase.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

final class MockDatabase {
    // MARK: - Auth

    var accessToken: String = "mock-access-token"
    var refreshToken: String = "mock-refresh-token"
    var deviceToken: String = "mock-device-token"
    var isCompleted: Bool = false

    // MARK: - Example feature

    var exampleItems: [MockExampleItem] = MockExampleItem.defaults

    // MARK: - Presets

    /// Switch the whole database to a named persona. Call from a mock
    /// provider when the user's first request identifies the scenario
    /// (e.g. `login(username:)` - phone number selects the persona).
    func applyPreset(for identifier: String) {
        switch identifier {
        case "fresh":
            accessToken = ""
            refreshToken = ""
            isCompleted = false
            exampleItems = []
        case "full":
            accessToken = "mock-access-token-full"
            refreshToken = "mock-refresh-token-full"
            isCompleted = true
            exampleItems = MockExampleItem.defaults
        default:
            break
        }
    }

    func reset() {
        accessToken = "mock-access-token"
        refreshToken = "mock-refresh-token"
        deviceToken = "mock-device-token"
        isCompleted = false
        exampleItems = MockExampleItem.defaults
    }
}

struct MockExampleItem: Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String?

    static let defaults: [MockExampleItem] = [
        .init(id: "1", title: "Alfred", subtitle: "Butler, Wayne Manor"),
        .init(id: "2", title: "Lucius Fox", subtitle: "Applied Sciences"),
        .init(id: "3", title: "Jim Gordon", subtitle: "Commissioner, GCPD")
    ]
}
