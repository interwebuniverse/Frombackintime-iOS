//
//  OBQuizSteps.swift
//  FromBackInTime
//
//  Act 3. A quiz block is ONE pushed screen that holds several questions
//  and animates between them in place. Only the question and answers swap,
//  with a spring transition. Between blocks we push empathy interstitials.
//

import SwiftUI

// MARK: - Quiz block

struct OBQuizBlockView: View {
    @Environment(OnboardingState.self) private var state
    let step: OnboardingStep
    let questions: [OBQuestion]

    @State private var index = 0

    private var question: OBQuestion { questions[index] }
    private var isLast: Bool { index == questions.count - 1 }
    private var canContinue: Bool { state.hasAnswer(for: question.id) }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("ob-sky-quiz")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        // Title/subtitle keep their identity so the text morphs
                        // with a numericText content transition on question change.
                        OBTitle(text: question.title, subtitle: question.subtitle)

                        // Answers are new content per question, so they swap with
                        // a blur-replace transition.
                        VStack(spacing: OnboardingTheme.answerSpacing) {
                            ForEach(question.options) { option in
                                OBChoiceRow(
                                    emoji: option.emoji,
                                    text: option.text,
                                    reveal: option.reveal,
                                    isSelected: state.isSelected(option.id, in: question.id),
                                    action: {
                                        state.toggle(option.id, in: question.id, multiSelect: question.multiSelect)
                                    }
                                )
                            }
                        }
                        .id(index)
                        .transition(.blurReplace)
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, AppSpacing.lg)
                    .animation(OnboardingTheme.questionSwap, value: index)
                }
                .scrollIndicators(.hidden)

                OBBottomBar(
                    title: isLast ? "Continue" : "Next",
                    enabled: canContinue,
                    action: advance
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func advance() {
        if isLast {
            state.advance(from: step)
        } else {
            index += 1   // animated by .animation(value: index) on the content
        }
    }
}

// MARK: - Empathy interstitial

struct OBEmpathyView: View {
    @Environment(OnboardingState.self) private var state
    let content: OBEmpathyContent
    @State private var appeared = false

    private var step: OnboardingStep {
        // Resolve which empathy step this is by matching content.
        content.kicker == OnboardingContent.empathyOne.kicker ? .empathyOne : .empathyTwo
    }

    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image(content.image)
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
                VStack(spacing: AppSpacing.sm) {
                    Text(content.kicker)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.accent)
                    Text(content.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(content.body)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, AppSpacing.xs)
                }
                .padding(.bottom, AppSpacing.xl)

                Button("Continue") { state.advance(from: step) }
                    .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}
