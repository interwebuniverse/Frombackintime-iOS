//
//  AppSpacing.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//
//  Spacing and radius tokens. Use these instead of hardcoded values
//  so the entire app scales from one place.

import CoreGraphics

enum AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let xxxxl: CGFloat = 48
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 9999
}
