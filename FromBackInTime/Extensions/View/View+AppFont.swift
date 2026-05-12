//
//  View+AppFont.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

extension View {
    func appFont(_ typography: AppTypography) -> some View {
        self.font(.app(typography))
    }
}
