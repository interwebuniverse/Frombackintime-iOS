//
//  OBAuthSteps.swift
//  FromBackInTime
//
//  Act 8. The sign-in gate, placed right after the plan reveal when the
//  user's investment is highest: keep the vault by attaching a real account.
//  The Apple/Google pair lives in SignInControls (shared with the in-app
//  SignInSheet). Skipping keeps the anonymous session; creating anything
//  later will ask again. Returning users ("I already have an account") go
//  straight into the app from here.
//

import SwiftUI

struct OBAuthGateView: View {
    @Environment(OnboardingState.self) private var state
    @Environment(AuthStore.self) private var authStore
    @Environment(AppState.self) private var appState

    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-vault")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.5), Self.skyBottom.opacity(0.96)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                Image("ob-d-shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 84, height: 84)
                    .padding(.bottom, AppSpacing.lg)

                VStack(spacing: AppSpacing.sm) {
                    Text(state.isReturningUser ? "Welcome back." : "Make your vault yours.")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(state.isReturningUser
                         ? "Sign in and your vault picks up right where you left it."
                         : "Sign in so your messages outlive this phone and no one else can ever claim them.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, AppSpacing.xxl)

                SignInControls(
                    onSignedIn: { advance() },
                    onAppleName: { given in
                        // Keep it for the greeting when the story never asked.
                        if state.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            state.name = given
                        }
                    }
                )

                Button("Skip for now") { advance() }
                    .textButton()
                    .a11y("ob.auth.skip")
                    .padding(.top, AppSpacing.lg)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }

    // Returning users ("I already have an account") go straight into the app,
    // signed in or skipped; new users continue to the closing screen.
    private func advance() {
        if state.isReturningUser {
            appState.completeOnboarding()
        } else {
            state.advance(from: .authGate)
        }
    }
}
