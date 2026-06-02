//
//  AppBackground.swift
//  FromBackInTime
//
//  Shared soft-cloudscape backdrop used behind every main screen. Image is
//  full-bleed, with a gentle bottom-to-top scrim so cards and text stay
//  legible without the photo feeling like a banner.
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        GeometryReader { proxy in
            Image(AppShellTheme.backgroundImage)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            .clear,
                            AppShellTheme.backgroundBottom.opacity(0.35),
                            AppShellTheme.backgroundBottom.opacity(0.7)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
        }
        .ignoresSafeArea()
    }
}
