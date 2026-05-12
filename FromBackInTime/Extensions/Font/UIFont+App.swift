//
//  UIFont+App.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import UIKit

extension UIFont {
    static func app(_ typography: AppTypography) -> UIFont {
        if let name = typography.customFontName {
            return UIFont(name: name, size: typography.size)
                ?? .systemFont(ofSize: typography.size, weight: typography.weight.uiKitWeight)
        }
        return .systemFont(ofSize: typography.size, weight: typography.weight.uiKitWeight)
    }
}

extension AppFontWeight {
    var uiKitWeight: UIFont.Weight {
        switch self {
        case .regular:  return .regular
        case .medium:   return .medium
        case .semibold: return .semibold
        case .bold:     return .bold
        }
    }
}
