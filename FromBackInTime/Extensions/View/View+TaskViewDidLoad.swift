//
//  View+TaskViewDidLoad.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

fileprivate struct TaskViewDidLoad: ViewModifier {
    @State private var viewDidLoad = false
    private let action: () async -> Void
    
    init(action: @escaping @Sendable () async -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                guard !viewDidLoad else { return }
                
                await action()
                
                viewDidLoad = true
            }
    }
}

extension View {
    func taskViewDidLoad(
        action: @escaping @Sendable () async -> Void
    ) -> some View {
        self
            .modifier(TaskViewDidLoad(action: action))
    }
}
