//
//  Router+Extension.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

struct AppRouter: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: RouterDestination.self) { destination in
                RouterDestinationView(destination: destination)
            }
    }
}

extension View {
    func withAppRouter() -> some View {
        modifier(AppRouter())
    }
}
