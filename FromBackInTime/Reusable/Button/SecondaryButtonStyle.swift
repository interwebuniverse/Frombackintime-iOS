//
//  SecondaryButtonStyle.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let leftIcon: Image?
    let rightIcon: Image?

    private let iconSize: CGFloat = 20
    private let iconGap: CGFloat = AppSpacing.sm
    private let cornerRadius: CGFloat = AppRadius.full
    private let height: CGFloat = 56

    init(leftIcon: Image? = nil, rightIcon: Image? = nil) {
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: iconGap) {
            if let leftIcon {
                leftIcon
                    .renderingMode(.template)
                    .frame(width: iconSize, height: iconSize)
            }
            configuration.label
            if let rightIcon {
                rightIcon
                    .renderingMode(.template)
                    .frame(width: iconSize, height: iconSize)
            }
        }
        .appFont(.heading5)
        .foregroundStyle(isEnabled ? Color.appPrimary : Color.appDisabledText)
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            isEnabled ? Color.appSecondaryButtonBackground : Color.appDisabledBackground,
            in: .rect(cornerRadius: cornerRadius)
        )
        .scaleEffect(configuration.isPressed ? 0.97 : 1)
        .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func secondaryButton(leftIcon: Image? = nil, rightIcon: Image? = nil) -> some View {
        self.buttonStyle(SecondaryButtonStyle(leftIcon: leftIcon, rightIcon: rightIcon))
    }
}
