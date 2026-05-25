//
//  Color+App.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI
import UIKit

// MARK: - Dynamic helper

private extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

// MARK: - Raw palette (replace with your brand)

extension UIColor {
    // Neutrals
    static let neutral50  = UIColor(hex: 0xFAFAFA)
    static let neutral100 = UIColor(hex: 0xF5F5F5)
    static let neutral200 = UIColor(hex: 0xE5E5E5)
    static let neutral300 = UIColor(hex: 0xD4D4D4)
    static let neutral400 = UIColor(hex: 0xA3A3A3)
    static let neutral500 = UIColor(hex: 0x737373)
    static let neutral600 = UIColor(hex: 0x525252)
    static let neutral700 = UIColor(hex: 0x404040)
    static let neutral800 = UIColor(hex: 0x262626)
    static let neutral900 = UIColor(hex: 0x171717)
    static let neutral950 = UIColor(hex: 0x0A0A0A)

    // Brand (swap these for your project's accent)
    static let brand50  = UIColor(hex: 0xEFF6FF)
    static let brand100 = UIColor(hex: 0xDBEAFE)
    static let brand200 = UIColor(hex: 0xBFDBFE)
    static let brand300 = UIColor(hex: 0x93C5FD)
    static let brand400 = UIColor(hex: 0x60A5FA)
    static let brand500 = UIColor(hex: 0x3B82F6)
    static let brand600 = UIColor(hex: 0x2563EB)
    static let brand700 = UIColor(hex: 0x1D4ED8)

    // Status
    static let statusRed    = UIColor(hex: 0xEF4444)
    static let statusGreen  = UIColor(hex: 0x22C55E)
    static let statusOrange = UIColor(hex: 0xF97316)
    static let statusBlue   = UIColor(hex: 0x3B82F6)
}

// MARK: - Semantic tokens (UIColor)

extension UIColor {
    static let appPrimary = dynamic(light: neutral900, dark: neutral50)
    static let appSecondary = dynamic(light: neutral500, dark: neutral400)

    // Warm cream surfaces (light-only app). Swap these to rebrand.
    static let appBackground = dynamic(light: UIColor(hex: 0xF4EEE1), dark: neutral950)
    static let appSurface = dynamic(light: UIColor(hex: 0xFBF8F1), dark: neutral900)
    static let appCardBackground = dynamic(light: UIColor(hex: 0xFBF8F1), dark: neutral800)
    static let appInputBackground = dynamic(light: UIColor(hex: 0xEAE1CF), dark: neutral800)
    static let appGroupedBackground = dynamic(light: UIColor(hex: 0xEAE1CF), dark: neutral950)

    static let appPlaceholder = dynamic(light: neutral400, dark: neutral600)
    static let appDisabledBackground = dynamic(light: neutral100, dark: neutral800.withAlphaComponent(0.4))
    static let appDisabledText = dynamic(light: neutral300, dark: neutral700)

    static let appBorder = dynamic(light: neutral200, dark: neutral700)
    static let appDivider = dynamic(light: neutral100, dark: neutral800)

    // Natural warm clay accent (replaces the blue) for text/secondary actions.
    static let appAccent = dynamic(light: UIColor(hex: 0xB5654D), dark: UIColor(hex: 0xC98060))
    static let appAccentBackground = dynamic(light: UIColor(hex: 0xF0E3D8), dark: neutral800)

    static let appPrimaryButtonBackground = dynamic(light: neutral900, dark: neutral50)
    static let appPrimaryButtonForeground = dynamic(light: .white, dark: neutral900)

    static let appSecondaryButtonBackground = dynamic(light: neutral100, dark: neutral800)

    static let appError = dynamic(light: statusRed, dark: statusRed)
    static let appSuccess = dynamic(light: statusGreen, dark: statusGreen)
    static let appWarning = dynamic(light: statusOrange, dark: statusOrange)
    static let appInfo = dynamic(light: statusBlue, dark: statusBlue)

    static let appErrorBackground = dynamic(light: UIColor(hex: 0xFEF2F2), dark: neutral800)
    static let appSuccessBackground = dynamic(light: UIColor(hex: 0xF0FDF4), dark: neutral800)
    static let appWarningBackground = dynamic(light: UIColor(hex: 0xFFFBEB), dark: neutral800)
}

// MARK: - Semantic tokens (SwiftUI Color)

extension Color {
    static let appPrimary = Color(UIColor.appPrimary)
    static let appSecondary = Color(UIColor.appSecondary)

    static let appBackground = Color(UIColor.appBackground)
    static let appSurface = Color(UIColor.appSurface)
    static let appCardBackground = Color(UIColor.appCardBackground)
    static let appInputBackground = Color(UIColor.appInputBackground)
    static let appGroupedBackground = Color(UIColor.appGroupedBackground)

    static let appPlaceholder = Color(UIColor.appPlaceholder)
    static let appDisabledBackground = Color(UIColor.appDisabledBackground)
    static let appDisabledText = Color(UIColor.appDisabledText)

    static let appBorder = Color(UIColor.appBorder)
    static let appDivider = Color(UIColor.appDivider)

    static let appAccent = Color(UIColor.appAccent)
    static let appAccentBackground = Color(UIColor.appAccentBackground)

    static let appPrimaryButtonBackground = Color(UIColor.appPrimaryButtonBackground)
    static let appPrimaryButtonForeground = Color(UIColor.appPrimaryButtonForeground)

    static let appSecondaryButtonBackground = Color(UIColor.appSecondaryButtonBackground)

    static let appError = Color(UIColor.appError)
    static let appSuccess = Color(UIColor.appSuccess)
    static let appWarning = Color(UIColor.appWarning)
    static let appInfo = Color(UIColor.appInfo)

    static let appErrorBackground = Color(UIColor.appErrorBackground)
    static let appSuccessBackground = Color(UIColor.appSuccessBackground)
    static let appWarningBackground = Color(UIColor.appWarningBackground)
}

// MARK: - Raw palette (SwiftUI Color)

extension Color {
    static let neutral50  = Color(UIColor.neutral50)
    static let neutral100 = Color(UIColor.neutral100)
    static let neutral200 = Color(UIColor.neutral200)
    static let neutral300 = Color(UIColor.neutral300)
    static let neutral400 = Color(UIColor.neutral400)
    static let neutral500 = Color(UIColor.neutral500)
    static let neutral600 = Color(UIColor.neutral600)
    static let neutral700 = Color(UIColor.neutral700)
    static let neutral800 = Color(UIColor.neutral800)
    static let neutral900 = Color(UIColor.neutral900)
    static let neutral950 = Color(UIColor.neutral950)

    static let brand50  = Color(UIColor.brand50)
    static let brand100 = Color(UIColor.brand100)
    static let brand200 = Color(UIColor.brand200)
    static let brand300 = Color(UIColor.brand300)
    static let brand400 = Color(UIColor.brand400)
    static let brand500 = Color(UIColor.brand500)
    static let brand600 = Color(UIColor.brand600)
    static let brand700 = Color(UIColor.brand700)
}
