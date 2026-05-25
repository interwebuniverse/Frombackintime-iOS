//
//  OnboardingStep.swift
//  FromBackInTime
//
//  Every screen in the flow as one ordered enum. The order array drives
//  linear navigation and the progress bar. Quiz blocks are a single step
//  that holds several questions and animates between them internally.
//

import Foundation

enum OnboardingStep: Hashable {
    // Act 1 - Hook (cinematic, no progress bar)
    case hookOpen
    case hookQuestion
    case hookPromise

    // Act 2 - Personalize
    case nameInput
    case welcome

    // Act 3 - Personal questions + empathy interstitials
    case quizBlockOne
    case empathyOne
    case quizBlockTwo
    case empathyTwo

    // Act 4 - Pain points
    case painStat
    case painUnsaid
    case painProtect

    // Act 5 - The turn (how we solve it)
    case thesis
    case authority
    case audience
    case science
    case ctmIntro

    // Act 6 - Feature reveals
    case featureRecord
    case featureSchedule
    case featureSecure
    case featureDeliver
    case featureCTM
    case featureRecipients

    // Act 7 - Make them believe
    case socialProof
    case comparison
    case preferences

    // Act 8 - Crescendo
    case loader
    case crescendo
    case planReveal

    // Act 9 - Close
    case firstAction

    /// Linear order of the whole flow. First element is the stack root.
    static let order: [OnboardingStep] = [
        .hookOpen, .hookQuestion,
        .nameInput, .welcome,
        .quizBlockOne, .empathyOne, .quizBlockTwo, .empathyTwo,
        .painStat, .painUnsaid, .painProtect,
        .thesis, .authority, .audience, .science, .ctmIntro,
        .featureRecord, .featureSchedule, .featureSecure,
        .featureDeliver, .featureCTM, .featureRecipients,
        .socialProof, .comparison, .preferences,
        .loader, .crescendo, .planReveal,
        .firstAction
    ]

    var index: Int { Self.order.firstIndex(of: self) ?? 0 }

    /// Progress 0...1 across the whole flow.
    var progress: Double {
        Double(index) / Double(Self.order.count - 1)
    }

    /// Cinematic hook screens hide the progress bar.
    var showsProgress: Bool {
        switch self {
        case .hookOpen, .hookQuestion, .hookPromise: return false
        default: return true
        }
    }
}
