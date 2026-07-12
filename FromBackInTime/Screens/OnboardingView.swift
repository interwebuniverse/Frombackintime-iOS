//
//  OnboardingView.swift
//  FromBackInTime
//
//  Root of the onboarding flow. Owns its own NavigationStack so every step
//  is a real pushed destination with the native iOS back button. Each step
//  renders its own layout; shared chrome (progress bar) lives here.
//

import SwiftUI

struct OnboardingView: View {
    @State private var state = OnboardingState()

    var body: some View {
        NavigationStack(path: $state.path) {
            OnboardingStepScreen(step: .hookOpen)
                .navigationDestination(for: OnboardingStep.self) { step in
                    OnboardingStepScreen(step: step)
                }
        }
        .a11y("onboarding.screen")
        .environment(state)
        .tint(OnboardingTheme.accent)
        .onAppear {
#if DEBUG
            // Debug shortcut: launch with `-ob-jump N` to open the flow at
            // OnboardingStep.order[N] without tapping through every screen.
            let jump = UserDefaults.standard.integer(forKey: "ob-jump")
            if jump > 0, jump < OnboardingStep.order.count, state.path.isEmpty {
                state.path = Array(OnboardingStep.order[1...jump])
            }
#endif
        }
    }
}

/// Resolves a step to its view and applies the shared navigation chrome.
struct OnboardingStepScreen: View {
    let step: OnboardingStep

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(step == .hookOpen)
            .toolbarBackground(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .hookOpen:        OBHookOpenView()
        case .hookQuestion:    OBHookQuestionView()

        case .nameInput:       OBNameInputView()

        case .quizBlockOne:    OBQuizBlockView(step: .quizBlockOne, questions: OnboardingContent.blockOne)
        case .empathyOne:      OBEmpathyView(content: OnboardingContent.empathyOne)
        case .quizBlockTwo:    OBQuizBlockView(step: .quizBlockTwo, questions: OnboardingContent.blockTwo)

        case .painStat:        OBPainStatView()
        case .thesis:          OBThesisView()

        case .featureShowcase: OBFeatureShowcaseView()
        case .ctmIntro:        OBCTMIntroView()

        case .socialProof:     OBSocialProofView()
        case .preferences:     OBPreferencesView()

        case .loader:          OBLoaderView()
        case .planReveal:      OBPlanRevealView()

        case .authGate:        OBAuthGateView()
        case .firstAction:     OBFirstActionView()
        }
    }
}

#Preview {
    PreviewContainer {
        OnboardingView()
    }
}
