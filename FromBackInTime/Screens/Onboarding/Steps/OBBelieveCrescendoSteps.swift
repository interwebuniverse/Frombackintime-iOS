//
//  OBBelieveCrescendoSteps.swift
//  FromBackInTime
//
//  Act 6 (social proof, preferences) and Act 7 (loader, plan reveal).
//

import SwiftUI

// MARK: - Act 6: social proof

struct OBSocialProofView: View {
    @Environment(OnboardingState.self) private var state

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
                    VStack(spacing: AppSpacing.xl) {
                        HStack(alignment: .center, spacing: AppSpacing.sm) {
                            Image(systemName: "laurel.leading")
                                .font(.system(size: 64, weight: .regular))
                                .foregroundStyle(OnboardingTheme.gold)
                            VStack(spacing: AppSpacing.xs) {
                                Text("\(OnboardingContent.averageRating, specifier: "%.1f")")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(OnboardingTheme.title)
                                HStack(spacing: 3) {
                                    ForEach(0..<5, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 15))
                                            .foregroundStyle(OnboardingTheme.gold)
                                    }
                                }
                                Text("average rating")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(OnboardingTheme.title.opacity(0.55))
                            }
                            Image(systemName: "laurel.trailing")
                                .font(.system(size: 64, weight: .regular))
                                .foregroundStyle(OnboardingTheme.gold)
                        }
                        .padding(.top, AppSpacing.lg)

                        HStack(spacing: AppSpacing.xl) {
                            statBlock(target: OnboardingContent.ratingCount, suffix: "+", label: "ratings")
                            statBlock(target: OnboardingContent.messagesDelivered, suffix: "+", label: "messages held safe")
                        }

                        ForEach(OnboardingContent.reviews) { review in
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                HStack(spacing: AppSpacing.md) {
                                    Image(review.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
                                        .clipShape(.circle)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(review.name), \(review.age)")
                                            .appFont(.labelL)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(OnboardingTheme.title)
                                        HStack(spacing: AppSpacing.xs) {
                                            ForEach(0..<5, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(OnboardingTheme.gold)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                Text("\u{201C}\(review.quote)\u{201D}")
                                    .appFont(.bodyM)
                                    .foregroundStyle(OnboardingTheme.title)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(AppSpacing.lg)
                            .background(OnboardingTheme.card, in: .rect(cornerRadius: OnboardingTheme.cardCornerRadius))
                            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, AppSpacing.lg)
                }
                .scrollIndicators(.hidden)

                OBBottomBar(title: "Continue") { state.advance(from: .socialProof) }
            }
        }
    }

    private func statBlock(target: Int, suffix: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            OBCountUp(target: target, suffix: suffix, typography: .heading2)
                .fontWeight(.bold)
                .foregroundStyle(OnboardingTheme.title)
            Text(label)
                .appFont(.bodyS)
                .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Act 6: preferences

struct OBPreferencesView: View {
    @Environment(OnboardingState.self) private var state

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
                        OBTitle(
                            text: "How would you like this to feel?",
                            subtitle: "Pick anything that matters to you. You can change all of it later."
                        )
                        VStack(spacing: OnboardingTheme.answerSpacing) {
                            ForEach(OnboardingContent.preferenceOptions) { option in
                                OBChoiceRow(
                                    emoji: option.emoji,
                                    text: option.text,
                                    reveal: nil,
                                    isSelected: state.preferences.contains(option.id),
                                    action: {
                                        if state.preferences.contains(option.id) {
                                            state.preferences.remove(option.id)
                                        } else {
                                            state.preferences.insert(option.id)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, AppSpacing.lg)
                }
                .scrollIndicators(.hidden)

                OBBottomBar(title: "Continue") { state.advance(from: .preferences) }
            }
        }
    }
}

// MARK: - Act 7: personalization loader

struct OBLoaderView: View {
    @Environment(OnboardingState.self) private var state

    private let steps = [
        "Securing your private space",
        "Calibrating your delivery schedule",
        "Setting up your gentle check-ins",
        "Preparing your first message prompt",
        "Sealing it with end-to-end encryption"
    ]

    @State private var progress: [Double]
    @State private var done = false

    init() { _progress = State(initialValue: Array(repeating: 0, count: 5)) }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("ob-sky-thesis")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                OBTitle(
                    text: "Preparing your vault\u{2026}",
                    subtitle: "This will take a moment."
                )
                .padding(.top, AppSpacing.xxxl)

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    ForEach(steps.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(steps[i])
                                .appFont(.bodyM)
                                .foregroundStyle(OnboardingTheme.title)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(.white.opacity(0.6))
                                    Capsule().fill(OnboardingTheme.highlight)
                                        .frame(width: progress[i] * geo.size.width)
                                }
                            }
                            .frame(height: 6)
                        }
                    }
                }

                Spacer()

                Text("\u{201C}What you leave behind is not what you carve in stone, but what you weave into the lives of others.\u{201D}")
                    .appFont(.bodyS)
                    .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Button("I'm ready") { state.advance(from: .loader) }
                    .primaryButton()
                    .opacity(done ? 1 : 0.45)
                    .disabled(!done)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear(perform: run)
    }

    private func run() {
        for i in steps.indices {
            withAnimation(.easeInOut(duration: 0.7).delay(Double(i) * 0.6)) {
                progress[i] = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 0.6 + 0.5) {
            withAnimation(OnboardingTheme.bounce) { done = true }
        }
    }
}

// MARK: - Act 7: plan reveal

struct OBPlanRevealView: View {
    @Environment(OnboardingState.self) private var state

    private var deliveryDate: String {
        let date = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f.string(from: date)
    }

    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-plan")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.5), Self.skyBottom.opacity(0.96)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: AppSpacing.md) {
                    Text("Your vault is ready, \(state.displayName).")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Your first message can arrive as soon as")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                        .multilineTextAlignment(.center)

                    Text(deliveryDate)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.highlight)
                        .padding(.vertical, AppSpacing.md)
                        .padding(.horizontal, AppSpacing.xxl)
                        .background(Color.white, in: .capsule)
                        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 5)
                        .padding(.top, AppSpacing.xs)

                    Text("Everything you record is encrypted and waiting. You're in control of every date and recipient.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, AppSpacing.xs)
                }
                .padding(.bottom, AppSpacing.xl)

                Button("Start sending forward") { state.advance(from: .planReveal) }
                    .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}
