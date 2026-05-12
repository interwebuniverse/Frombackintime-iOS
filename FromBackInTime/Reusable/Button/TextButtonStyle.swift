//
//  TextButtonStyle.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

struct TextButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let leftIcon: Image?
    let rightIcon: Image?

    private let iconSize: CGFloat = 20
    private let iconGap: CGFloat = 8

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
        .appFont(.labelS)
        .foregroundStyle(isEnabled ? Color.appAccent : Color.appDisabledText)
        .scaleEffect(configuration.isPressed ? 0.97 : 1)
        .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func textButton(leftIcon: Image? = nil, rightIcon: Image? = nil) -> some View {
        self.buttonStyle(TextButtonStyle(leftIcon: leftIcon, rightIcon: rightIcon))
    }
}
