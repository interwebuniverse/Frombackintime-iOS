//
//  VSpacer.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

struct VSpacer: View {
    private let spacing: CGFloat
    
    init(_ spacing: CGFloat) {
        self.spacing = spacing
    }
    
    var body: some View {
        Spacer()
            .frame(height: spacing)
    }
}
