//
//  View+HiddenIf.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func hiddenIf(_ condition: Bool) -> some View {
        if !condition {
            self
        }
    }
}
