//
//  Router+Sheet.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

struct AppSheetRouter: ViewModifier {
    @Binding var sheet: RouterDestination?
    @Binding var fullScreenSheet: RouterDestination?

    func body(content: Content) -> some View {
        content
            .sheet(item: $sheet) { destination in
                RouterDestinationView(destination: destination)
            }
            .fullScreenCover(item: $fullScreenSheet) { destination in
                RouterDestinationView(destination: destination)
            }
    }
}

extension View {
    func withAppSheet(
        sheet: Binding<RouterDestination?> = .constant(nil),
        fullScreenSheet: Binding<RouterDestination?> = .constant(nil)
    ) -> some View {
        modifier(AppSheetRouter(sheet: sheet, fullScreenSheet: fullScreenSheet))
    }
}
