//
//  OBFeatureSteps.swift
//  FromBackInTime
//
//  Act 5. The whole product story on ONE screen: a swipeable pager where
//  each page leads with a floating icon composition, a title, and one line.
//  Replaces the old run of six near-identical feature screens.
//

import SwiftUI

struct OBFeatureShowcaseView: View {
    @Environment(OnboardingState.self) private var state

    @State private var page = 0
    private let pages = OnboardingContent.showcasePages

    private static let skyBottom = Color(red: 206/255, green: 224/255, blue: 240/255)
    private var isLast: Bool { page == pages.count - 1 }

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-features")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.45), Self.skyBottom.opacity(0.92)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Text("How it works")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(OnboardingTheme.title.opacity(0.55))
                    .padding(.top, AppSpacing.lg)

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { i in
                        OBShowcasePageView(page: pages[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: page) { Haptics.feedback(style: .soft) }

                HStack(spacing: AppSpacing.sm) {
                    ForEach(pages.indices, id: \.self) { i in
                        Capsule()
                            .fill(OnboardingTheme.title.opacity(i == page ? 0.9 : 0.25))
                            .frame(width: i == page ? 22 : 7, height: 7)
                    }
                }
                .animation(OnboardingTheme.questionSwap, value: page)
                .padding(.bottom, AppSpacing.xl)

                Button(isLast ? "Continue" : "Next") {
                    if isLast {
                        state.advance(from: .featureShowcase)
                    } else {
                        withAnimation(.easeInOut(duration: 0.4)) { page += 1 }
                    }
                }
                .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}

// MARK: - One showcase page

private struct OBShowcasePageView: View {
    let page: OBShowcasePage
    @State private var floating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero composition: big icon in a soft white disc, two satellite
            // icons orbiting it. The whole cluster drifts gently.
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 190, height: 190)
                    .shadow(color: .black.opacity(0.10), radius: 24, x: 0, y: 10)
                Image(page.hero)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 116, height: 116)

                satellite(page.satellites.first, size: 64)
                    .offset(x: -96, y: -62)
                satellite(page.satellites.count > 1 ? page.satellites[1] : nil, size: 56)
                    .offset(x: 100, y: 44)
            }
            .offset(y: floating ? -7 : 7)
            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: floating)
            .onAppear { floating = true }

            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(OnboardingTheme.title)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(page.subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, AppSpacing.xl)
        }
    }

    @ViewBuilder
    private func satellite(_ name: String?, size: CGFloat) -> some View {
        if let name {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.6, height: size * 0.6)
            }
            .frame(width: size, height: size)
        }
    }
}
