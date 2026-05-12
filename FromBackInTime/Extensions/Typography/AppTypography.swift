//
//  AppTypography.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import CoreGraphics

enum AppTypography {
    case heading1   // 28pt semibold
    case heading2   // 24pt semibold
    case heading3   // 20pt semibold
    case heading4   // 18pt semibold
    case heading5   // 16pt semibold
    case heading6   // 14pt semibold

    case bodyL      // 18pt regular
    case bodyM      // 16pt regular
    case bodyS      // 14pt regular
    case bodyXS     // 12pt regular

    case labelL     // 16pt medium
    case labelS     // 14pt medium
    case labelXS    // 12pt medium

    case caption    // 11pt regular

    var size: CGFloat {
        switch self {
        case .heading1: 28
        case .heading2: 24
        case .heading3: 20
        case .heading4: 18
        case .heading5: 16
        case .heading6: 14
        case .bodyL:    18
        case .bodyM:    16
        case .bodyS:    14
        case .bodyXS:   12
        case .labelL:   16
        case .labelS:   14
        case .labelXS:  12
        case .caption:  11
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .heading1: 36
        case .heading2: 32
        case .heading3: 28
        case .heading4: 26
        case .heading5: 24
        case .heading6: 20
        case .bodyL:    28
        case .bodyM:    24
        case .bodyS:    20
        case .bodyXS:   16
        case .labelL:   24
        case .labelS:   20
        case .labelXS:  16
        case .caption:  14
        }
    }

    /// Return a custom font PostScript name here when you add bundled fonts.
    /// For system font, return nil and the `Font.app(_:)` extension
    /// will use `.system(size:weight:)` instead.
    var customFontName: String? {
        // Example for Montserrat:
        // switch self {
        // case .heading1, .heading2, .heading3, .heading4, .heading5, .heading6:
        //     return "Montserrat-SemiBold"
        // case .labelL, .labelS, .labelXS:
        //     return "Montserrat-Medium"
        // default:
        //     return "Montserrat-Regular"
        // }
        return nil
    }

    var weight: AppFontWeight {
        switch self {
        case .heading1, .heading2, .heading3, .heading4, .heading5, .heading6:
            return .semibold
        case .labelL, .labelS, .labelXS:
            return .medium
        default:
            return .regular
        }
    }
}

enum AppFontWeight {
    case regular
    case medium
    case semibold
    case bold
}
