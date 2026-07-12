//
//  OnboardingStep.swift
//  FromBackInTime
//
//  Every screen in the flow as one ordered enum. The order array drives
//  linear navigation and the progress bar. Quiz blocks are a single step
//  that holds several questions and animates between them internally, and
//  the feature showcase is one step that pages through the product story.
//

import Foundation

enum OnboardingStep: Hashable {
    // Act 1 - Hook (cinematic, no progress bar)
    case hookOpen
    case hookQuestion

    // Act 2 - Personalize
    case nameInput

    // Act 3 - Personal questions + one empathy payoff
    case quizBlockOne
    case empathyOne
    case quizBlockTwo

    // Act 4 - The pain, then the turn
    case painStat
    case thesis

    // Act 5 - The product, shown not listed
    case featureShowcase
    case ctmIntro

    // Act 6 - Believe
    case socialProof
    case preferences

    // Act 7 - Crescendo
    case loader
    case planReveal

    // Act 8 - Keep it, then close
    case authGate
    case firstAction

    /// Linear order of the whole flow. First element is the stack root.
    static let order: [OnboardingStep] = [
        .hookOpen, .hookQuestion,
        .nameInput,
        .quizBlockOne, .empathyOne, .quizBlockTwo,
        .painStat, .thesis,
        .featureShowcase, .ctmIntro,
        .socialProof, .preferences,
        .loader, .planReveal,
        .authGate, .firstAction
    ]

    var index: Int { Self.order.firstIndex(of: self) ?? 0 }

    /// Progress 0...1 across the whole flow.
    var progress: Double {
        Double(index) / Double(Self.order.count - 1)
    }

    /// Cinematic hook screens hide the progress bar.
    var showsProgress: Bool {
        switch self {
        case .hookOpen, .hookQuestion: return false
        default: return true
        }
    }
}
