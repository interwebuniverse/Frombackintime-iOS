//
//  SpinningLoader.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

struct SpinningLoader: View {
    @State private var isRotating = false
    
    let size: CGFloat
    let color: Color
    let lineWidth: CGFloat
    
    init(size: CGFloat = 40, color: Color = .white, lineWidth: CGFloat = 4) {
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(
                color.opacity(0.8),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

#Preview {
    SpinningLoader(size: 40, color: .black, lineWidth: 2)
}
