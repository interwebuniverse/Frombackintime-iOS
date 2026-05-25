//
//  LaunchView.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import SwiftUI

struct LaunchView: View {
    @Environment(Router.self) private var router
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Text(L10n.launchTitle.localized)
                    .appFont(.heading1)
                    .foregroundStyle(Color.appPrimary)
                Text("Environment: \(container.environment.isMock ? "Mock" : "Live")")
                    .appFont(.bodyS)
                    .foregroundStyle(Color.appSecondary)
            }

            Spacer()

            VStack(spacing: AppSpacing.md) {
                Button(L10n.launchOpenExample.localized) {
                    router.navigate(.example)
                }
                .primaryButton()

                Button(L10n.launchOnboarding.localized) {
                    router.presentFullScreen(.onboarding)
                }
                .secondaryButton()
            }
            .padding(.horizontal, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    PreviewContainer {
        LaunchView()
    }
}
