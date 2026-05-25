//
//  OBHookSteps.swift
//  FromBackInTime
//
//  Act 1 (cinematic hook) + Act 2 (personalize). Dark, quiet screens that
//  sell the feeling before asking for anything.
//

import SwiftUI

// MARK: - Cinematic background helper

private extension View {
    func obCinematic() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(OnboardingTheme.cinematicBackground.ignoresSafeArea())
    }
}

// MARK: - Screen 1: cold open

struct OBHookOpenView: View {
    @Environment(OnboardingState.self) private var state
    @State private var appeared = false

    // Matches the bottom tone of the sky illustration so the scrim blends.
    private static let skyBottom = Color(red: 216/255, green: 226/255, blue: 235/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed cloudscape, sized to the proxy so it fills the screen
            // exactly and never overflows the edges.
            GeometryReader { proxy in
                Image("ob-hero")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            // Soft scrim matched to the sky's bottom tone so the button grounds
            // without clashing with the blue.
            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.45), Self.skyBottom.opacity(0.92)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Content respects the safe area, so spacing matches the rest of the
            // onboarding: brand at top, hook in the middle, button lifted off the
            // bottom by the standard padding.
            VStack(spacing: 0) {
                HStack(spacing: AppSpacing.sm) {
                    Image("ob-app-icon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text("frombackintime.")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                }
                .padding(.top, AppSpacing.sm)
                .opacity(appeared ? 1 : 0)

                Spacer()

                VStack(spacing: AppSpacing.md) {
                    Text("Some words deserve\nthe right moment.")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Record what matters now. We'll keep it safe and deliver it exactly when it should arrive, even years from now.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)

                Spacer()

                Button("Begin") { state.advance(from: .hookOpen) }
                    .primaryButton()
                    .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) { appeared = true }
        }
    }
}

// MARK: - Screen 2: the question that hooks

struct OBHookQuestionView: View {
    @Environment(OnboardingState.self) private var state
    @State private var typingDone = false

    private static let skyBottom = Color(red: 222/255, green: 232/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-question")
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

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Spacer()
                Text("A question.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                OBTypingText(
                    text: "What would you say to someone, if you knew you might not get the chance again?",
                    size: 34,
                    onComplete: { withAnimation(.easeOut(duration: 0.3)) { typingDone = true } }
                )
                Spacer()
                Button("Continue") { state.advance(from: .hookQuestion) }
                    .primaryButton()
                    .disabled(!typingDone)
                    .opacity(typingDone ? 1 : 0.45)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}

// MARK: - Screen 3: the promise

struct OBHookPromiseView: View {
    @Environment(OnboardingState.self) private var state

    private static let skyBottom = Color(red: 198/255, green: 220/255, blue: 238/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-promise")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.5), Self.skyBottom.opacity(0.95)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: AppSpacing.md) {
                    Text("Send what matters.\nTo the people who matter.")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Record now. We'll keep it safe and deliver it exactly when the moment is right.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, AppSpacing.xl)

                Button("Begin") { state.advance(from: .hookPromise) }
                    .primaryButton()
                Button("I already have an account") { }
                    .textButton()
                    .padding(.top, AppSpacing.xs)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}

// MARK: - Screen 4: name

struct OBNameInputView: View {
    @Environment(OnboardingState.self) private var state
    @FocusState private var focused: Bool

    private static let skyBottom = Color(red: 206/255, green: 224/255, blue: 240/255)
    private var canContinue: Bool { !state.name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-name")
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
                VStack(spacing: AppSpacing.sm) {
                    Text("What should we\ncall you?")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Just a first name. We're getting to know you, not signing you up.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, AppSpacing.xxl)

                Spacer()

                // Borderless floating field, big and centered.
                TextField("", text: Binding(get: { state.name }, set: { state.name = $0 }),
                          prompt: Text("Your name").foregroundColor(OnboardingTheme.title.opacity(0.3)))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(OnboardingTheme.title)
                    .tint(OnboardingTheme.accent)
                    .multilineTextAlignment(.center)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { if canContinue { state.advance(from: .nameInput) } }

                Spacer()

                Button("Continue") { state.advance(from: .nameInput) }
                    .primaryButton()
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1 : 0.45)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}

// MARK: - Screen 5: soft welcome

struct OBWelcomeView: View {
    @Environment(OnboardingState.self) private var state

    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-welcome")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.5), Self.skyBottom.opacity(0.95)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: AppSpacing.md) {
                    Text("Welcome, \(state.displayName).")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Take your time, there's no rush here. From now on, we'll shape everything around you and what matters to you.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, AppSpacing.xl)

                Button("Let's start") { state.advance(from: .welcome) }
                    .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}
