//
//  RouterDestinationView.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

struct RouterDestinationView: View {
    @Environment(DependencyContainer.self) private var container

    let destination: RouterDestination

    var body: some View {
        switch destination {
        case .onboarding:
            OnboardingView()
        case .example:
            ExampleView(store: container.makeExampleStore())
        }
    }
}
