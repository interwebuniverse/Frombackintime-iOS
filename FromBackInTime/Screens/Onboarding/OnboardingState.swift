//
//  OnboardingState.swift
//  FromBackInTime
//
//  Holds the user's answers and drives navigation. Injected into every
//  step via .environment(). The flow is linear: each step calls advance().
//

import SwiftUI

@MainActor
@Observable
final class OnboardingState {
    /// Navigation path. Root (hookOpen) is not in here.
    var path: [OnboardingStep] = []

    /// True when the user jumped to the auth gate via "I already have an
    /// account". Both sign-in and skip then go straight into the app instead
    /// of continuing the new-user story.
    var isReturningUser = false

    // Collected answers
    var name: String = ""
    /// Selected option ids keyed by question id.
    var answers: [String: Set<String>] = [:]
    /// Selected preferences from the preferences step.
    var preferences: Set<String> = []
    /// Chosen first-delivery window label, used in the plan reveal.
    var deliveryWindow: String = "1 year from today"

    var displayName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? "friend" : name
    }

    // MARK: - Navigation

    func advance(from step: OnboardingStep) {
        guard let i = OnboardingStep.order.firstIndex(of: step),
              i + 1 < OnboardingStep.order.count else { return }
        path.append(OnboardingStep.order[i + 1])
    }

    // MARK: - Answers

    func isSelected(_ optionID: String, in questionID: String) -> Bool {
        answers[questionID]?.contains(optionID) ?? false
    }

    func toggle(_ optionID: String, in questionID: String, multiSelect: Bool) {
        var set = answers[questionID] ?? []
        if multiSelect {
            if set.contains(optionID) { set.remove(optionID) } else { set.insert(optionID) }
        } else {
            set = set.contains(optionID) ? [] : [optionID]
        }
        answers[questionID] = set
    }

    func hasAnswer(for questionID: String) -> Bool {
        !(answers[questionID]?.isEmpty ?? true)
    }
}

// MARK: - Quiz models

struct OBOption: Identifiable {
    let id: String
    let emoji: String?
    let text: String
    let reveal: String?

    init(id: String, emoji: String? = nil, text: String, reveal: String? = nil) {
        self.id = id
        self.emoji = emoji
        self.text = text
        self.reveal = reveal
    }
}

struct OBQuestion: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let multiSelect: Bool
    let options: [OBOption]
}
