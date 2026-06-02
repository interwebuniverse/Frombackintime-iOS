//
//  PressableCardStyle.swift
//  FromBackInTime
//
//  A button style that gives any card-shaped tappable a subtle bouncy
//  press response: scales down, fades a touch, springs back. Use on
//  every tappable card so the whole UI feels alive without changing the
//  card's own visuals.
//

import SwiftUI

struct PressableCardStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    var pressedOpacity: Double = 0.92

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .animation(.spring(response: 0.30, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableCardStyle {
    static var pressableCard: PressableCardStyle { PressableCardStyle() }
}
