//
//  OBPainTurnSteps.swift
//  FromBackInTime
//
//  Act 4: the pain (one stat that lands) and the turn (the thesis), then
//  the Critical Timed Message intro that follows the feature showcase.
//

import SwiftUI

// MARK: - Act 4: stat that lands

struct OBPainStatView: View {
    @Environment(OnboardingState.self) private var state

    /// Bluish highlight that pops on the light sky and carries the emotion.
    private static let highlight = Color(red: 46/255, green: 128/255, blue: 238/255)
    private static let skyBottom = Color(red: 206/255, green: 224/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-stat")
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
                OBCountUp(target: 73, suffix: "%", bigSize: 168)
                    .foregroundStyle(Self.highlight)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("of people say there's something they wish they'd said before it was ")
                        .foregroundColor(OnboardingTheme.title)
                    + Text("too late.")
                        .foregroundColor(Self.highlight)
                )
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)

                Text("Hospice and end-of-life studies, 2014 to 2022.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(OnboardingTheme.title.opacity(0.55))
                    .padding(.top, AppSpacing.xs)

                Spacer()

                Text("\(state.displayName), you're not alone in this.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(OnboardingTheme.title.opacity(0.7))

                Button("Continue") { state.advance(from: .painStat) }
                    .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}

// MARK: - Act 4: thesis (the turn)

struct OBThesisView: View {
    @Environment(OnboardingState.self) private var state
    @State private var showSub = false
    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-thesis")
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
                OBTypingText(text: "You don't have to say it today.", size: 50)
                (
                    Text("You just have to say it ").foregroundColor(OnboardingTheme.title.opacity(0.7))
                    + Text("once.").foregroundColor(OnboardingTheme.highlight)
                    + Text(" We'll hold it until the right moment, and make sure it arrives.").foregroundColor(OnboardingTheme.title.opacity(0.7))
                )
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
                .opacity(showSub ? 1 : 0)
                Spacer()
                Button("Show me how") { state.advance(from: .thesis) }
                    .primaryButton()
                    .opacity(showSub ? 1 : 0)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.5)) { showSub = true }
            }
        }
    }
}

// MARK: - Act 5: Critical Timed Message intro

struct OBCTMIntroView: View {
    @Environment(OnboardingState.self) private var state

    private let steps: [(icon: String, title: String, detail: String)] = [
        ("ob-d-calendar", "We check in, gently", "A quiet tap on your schedule. One touch to confirm you're here."),
        ("ob-d-hourglass", "If you ever go quiet", "Miss enough check-ins and we know something has changed."),
        ("ob-d-envelope", "Your message is delivered", "It reaches the person you trusted it to, exactly as you left it.")
    ]

    @State private var stepsDone = false

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("ob-sky-ctm")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        OBTitle(
                            text: "Some messages should only arrive if you can't deliver them yourself.",
                            subtitle: "We call these Critical Timed Messages."
                        )

                        OBStepFlow(steps: steps, onComplete: {
                            withAnimation(.easeOut(duration: 0.3)) { stepsDone = true }
                        })

                        HStack(spacing: AppSpacing.md) {
                            OBIcon(name: "ob-hand-heart", size: 22)
                                .foregroundStyle(OnboardingTheme.accent)
                            Text("It's completely optional. Most people start with simpler messages first.")
                                .appFont(.bodyS)
                                .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(AppSpacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(OnboardingTheme.card, in: .rect(cornerRadius: OnboardingTheme.cardCornerRadius))
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                        .opacity(stepsDone ? 1 : 0)
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, AppSpacing.lg)
                }
                .scrollIndicators(.hidden)

                OBBottomBar(title: "Continue", enabled: stepsDone) {
                    state.advance(from: .ctmIntro)
                }
            }
        }
    }
}

// MARK: - Step flow diagram
// A vertical, connected three-step diagram. Conveys a process visually so a
// page like the Critical Timed Message intro doesn't rely on a paragraph.

struct OBStepFlow: View {
    let steps: [(icon: String, title: String, detail: String)]
    var onComplete: () -> Void = {}

    @State private var shown = 0   // number of steps revealed so far

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(steps.indices, id: \.self) { i in
                let visible = i < shown
                HStack(alignment: .top, spacing: AppSpacing.lg) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle().fill(OnboardingTheme.accent.opacity(0.06))
                            Image(steps[i].icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                        }
                        .frame(width: 56, height: 56)
                        .scaleEffect(visible ? 1 : 0.4)

                        if i < steps.count - 1 {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(OnboardingTheme.accent.opacity(0.35))
                                    .frame(width: 4, height: 4)
                                    .padding(.vertical, 3)
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(steps[i].title)
                            .appFont(.heading5)
                            .foregroundStyle(OnboardingTheme.title)
                        Text(steps[i].detail)
                            .appFont(.bodyS)
                            .foregroundStyle(OnboardingTheme.subtitle)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, i < steps.count - 1 ? AppSpacing.xl : 0)

                    Spacer(minLength: 0)
                }
                .opacity(visible ? 1 : 0)
                .offset(y: visible ? 0 : 14)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OnboardingTheme.card, in: .rect(cornerRadius: OnboardingTheme.cardCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
        .onAppear(perform: reveal)
    }

    // Steps pop in one after another with a bouncy spring, like progress
    // building, then notify the parent so the button can enable.
    private func reveal() {
        shown = 0
        for i in steps.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(i) * 0.5) {
                Haptics.feedback(style: .soft)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                    shown = i + 1
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(steps.count) * 0.5 + 0.2) {
            onComplete()
        }
    }
}
