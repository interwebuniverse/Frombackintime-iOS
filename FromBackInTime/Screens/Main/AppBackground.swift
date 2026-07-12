//
//  AppBackground.swift
//  FromBackInTime
//
//  Shared backdrop behind every main screen. Brings the onboarding sky into
//  the app so it feels like the same world, with a soft legibility veil so
//  titles and cards stay crisp. Opaque cards keep content readable over it.
//

import SwiftUI

struct AppBackground: View {
    /// Sky asset to show. Defaults to the calm app-wide sky; screens can pass
    /// their own for a little variety.
    var image: String = "ob-sky-quiz"

    var body: some View {
        GeometryReader { proxy in
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .overlay(
                    // Gentle veil: a touch of light at the very top for the big
                    // title, clearing through the middle so the sky reads, then
                    // easing to the cool canvas tone at the bottom behind the
                    // floating tab bar.
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.05),
                            .clear,
                            AppShellTheme.canvasBottom.opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .ignoresSafeArea()
    }
}
