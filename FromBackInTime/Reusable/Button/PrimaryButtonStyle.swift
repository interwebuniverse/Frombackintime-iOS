//
//  PrimaryButtonStyle.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let leftIcon: Image?
    let rightIcon: Image?
    let isLoading: Bool

    private let iconSize: CGFloat = 20
    private let iconGap: CGFloat = AppSpacing.sm
    private let cornerRadius: CGFloat = AppRadius.full
    private let height: CGFloat = 58

    init(leftIcon: Image? = nil, rightIcon: Image? = nil, isLoading: Bool = false) {
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.isLoading = isLoading
    }

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
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
            .opacity(isLoading ? 0 : 1)

            if isLoading {
                ProgressView()
                    .tint(Color.appPrimaryButtonForeground)
            }
        }
        .appFont(.heading4)
        .fontWeight(.bold)
        .foregroundStyle(Color.appPrimaryButtonForeground)
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            Color.appPrimaryButtonBackground,
            in: .rect(cornerRadius: cornerRadius)
        )
        .shadow(color: Color.appPrimaryButtonBackground.opacity(isEnabled ? 0.28 : 0), radius: 16, y: 8)
        .opacity(isEnabled || isLoading ? 1 : 0.45)
        .scaleEffect(configuration.isPressed && !isLoading ? 0.97 : 1)
        .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func primaryButton(
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        isLoading: Bool = false
    ) -> some View {
        self.buttonStyle(
            PrimaryButtonStyle(leftIcon: leftIcon, rightIcon: rightIcon, isLoading: isLoading)
        )
        .disabled(isLoading)
    }
}
