//
//  View+DebounceRefresh.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

struct DebounceRefresh: ViewModifier {
    @State private var lastRefreshDate: Date?
    let interval: TimeInterval
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content.refreshable {
            let now = Date()
            
            guard let lastRefreshDate else {
                self.lastRefreshDate = now
                action()
                return
            }
            
            guard now.timeIntervalSince(lastRefreshDate) > interval else { return }
            
            self.lastRefreshDate = now
            action()
        }
    }
}

struct DebounceRefreshAsync: ViewModifier {
    @State private var lastRefreshDate: Date?
    let interval: TimeInterval
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content.refreshable {
            let now = Date()
            
            guard let lastRefreshDate else {
                self.lastRefreshDate = now
                Task { await action() }
                return
            }
            
            guard now.timeIntervalSince(lastRefreshDate) > interval else { return }
            
            self.lastRefreshDate = now
            Task { await action() }
        }
    }
}

extension View {
    func debounceRefreshable(interval: TimeInterval = 5, action: @escaping () -> Void) -> some View {
        self.modifier(DebounceRefresh(interval: interval, action: action))
    }
    
    func debounceRefreshableAsync(interval: TimeInterval = 5, action: @Sendable @escaping () async -> Void) -> some View {
        self.modifier(DebounceRefreshAsync(interval: interval, action: action))
    }
}
