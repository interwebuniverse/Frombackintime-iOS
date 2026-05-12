//
//  View+Align.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

extension View {
    func leftAlign() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }
    
    func centerAlign() -> some View {
        self
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}
