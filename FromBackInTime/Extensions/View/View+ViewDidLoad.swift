//
//  View+ViewDidLoad.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

fileprivate struct ViewDidLoad: ViewModifier {
    @State private var viewDidLoad = false
    private let action: () -> Void
    
    init(action: @escaping ()  -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !viewDidLoad else { return }
                
                action()
                
                viewDidLoad = true
            }
    }
}

extension View {
    func viewDidLoad(
        action: @escaping () -> Void
    ) -> some View {
        self
            .modifier(ViewDidLoad(action: action))
    }
}
