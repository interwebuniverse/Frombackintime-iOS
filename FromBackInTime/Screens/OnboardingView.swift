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
        .environment(state)
        .tint(OnboardingTheme.accent)
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
        case .hookPromise:     OBHookPromiseView()

        case .nameInput:       OBNameInputView()
        case .welcome:         OBWelcomeView()

        case .quizBlockOne:    OBQuizBlockView(step: .quizBlockOne, questions: OnboardingContent.blockOne)
        case .empathyOne:      OBEmpathyView(content: OnboardingContent.empathyOne)
        case .quizBlockTwo:    OBQuizBlockView(step: .quizBlockTwo, questions: OnboardingContent.blockTwo)
        case .empathyTwo:      OBEmpathyView(content: OnboardingContent.empathyTwo)

        case .painStat:        OBPainStatView()
        case .painUnsaid:      OBPainUnsaidView()
        case .painProtect:     OBPainProtectView()

        case .thesis:          OBThesisView()
        case .authority:       OBAuthorityView()
        case .audience:        OBAudienceView()
        case .science:         OBScienceView()
        case .ctmIntro:        OBCTMIntroView()

        case .featureRecord:     OBFeatureView(step: .featureRecord, content: OnboardingContent.featureRecord)
        case .featureSchedule:   OBFeatureView(step: .featureSchedule, content: OnboardingContent.featureSchedule)
        case .featureSecure:     OBFeatureView(step: .featureSecure, content: OnboardingContent.featureSecure)
        case .featureDeliver:    OBFeatureView(step: .featureDeliver, content: OnboardingContent.featureDeliver)
        case .featureCTM:        OBFeatureView(step: .featureCTM, content: OnboardingContent.featureCTM)
        case .featureRecipients: OBFeatureView(step: .featureRecipients, content: OnboardingContent.featureRecipients)

        case .socialProof:     OBSocialProofView()
        case .comparison:      OBComparisonView()
        case .preferences:     OBPreferencesView()

        case .loader:          OBLoaderView()
        case .crescendo:       OBCrescendoView()
        case .planReveal:      OBPlanRevealView()

        case .firstAction:     OBFirstActionView()
        }
    }
}

#Preview {
    PreviewContainer {
        OnboardingView()
    }
}
