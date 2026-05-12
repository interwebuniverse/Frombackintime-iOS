//
//  View+AsButton.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

extension View {
    func button(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self.contentShape(Rectangle())
        }
    }
    
    func button(action: @Sendable @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            self.contentShape(Rectangle())
        }
    }
}
