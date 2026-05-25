//
//  Font+App.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

extension Font {
    static func app(_ typography: AppTypography) -> Font {
        if let name = typography.customFontName {
            return .custom(name, size: typography.size)
        }
        return .system(size: typography.size, weight: typography.weight.swiftUIWeight, design: .rounded)
    }
}

extension Font.Weight {
    init(_ weight: AppFontWeight) {
        switch weight {
        case .regular:  self = .regular
        case .medium:   self = .medium
        case .semibold: self = .semibold
        case .bold:     self = .bold
        }
    }
}

extension AppFontWeight {
    var swiftUIWeight: Font.Weight { Font.Weight(self) }
}
