//
//  OBPainTurnSteps.swift
//  FromBackInTime
//
//  Act 4 (pain points) and Act 5 (the turn: how we solve it).
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

// MARK: - Act 4: the words we never say

struct OBPainUnsaidView: View {
    @Environment(OnboardingState.self) private var state
    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-unsaid")
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
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    (
                        Text("The words we keep putting off ").foregroundColor(OnboardingTheme.title)
                        + Text("rarely get said.").foregroundColor(OnboardingTheme.highlight)
                    )
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)

                    (
                        Text("There's never a right time to say the deepest things, until suddenly ").foregroundColor(OnboardingTheme.title.opacity(0.7))
                        + Text("there's no time at all.").foregroundColor(OnboardingTheme.highlight)
                    )
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, AppSpacing.xl)

                Button("Continue") { state.advance(from: .painUnsaid) }
                    .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}

// MARK: - Act 4: the protect / dead man's switch fear

struct OBPainProtectView: View {
    @Environment(OnboardingState.self) private var state
    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                Image("ob-sky-protect")
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
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    (
                        Text("Some words shouldn't depend on ").foregroundColor(OnboardingTheme.title)
                        + Text("you being here ").foregroundColor(OnboardingTheme.highlight)
                        + Text("to say them.").foregroundColor(OnboardingTheme.title)
                    )
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)

                    (
                        Text("A parent. Someone living with illness. Anyone whose work or health carries ").foregroundColor(OnboardingTheme.title.opacity(0.7))
                        + Text("real risk.").foregroundColor(OnboardingTheme.highlight)
                    )
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, AppSpacing.xl)

                Button("Show me how it works") { state.advance(from: .painProtect) }
                    .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
    }
}

// MARK: - Act 5: thesis

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
                Button("Continue") { state.advance(from: .thesis) }
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

// MARK: - Act 5: authority

struct OBAuthorityView: View {
    @Environment(OnboardingState.self) private var state

    private let pillars: [(icon: String, label: String)] = [
        ("ob-hand-heart", "Grief counselors"),
        ("ob-lock-key", "Cryptographers"),
        ("ob-scroll", "Estate planners")
    ]

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("ob-sky-authority")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        OBTitle(
                            text: "\(state.displayName), you're in careful hands.",
                            subtitle: "We built this slowly, with the help of people who do this for a living.",
                            alignment: .center
                        )

                        VStack(spacing: AppSpacing.md) {
                            ForEach(pillars, id: \.label) { pillar in
                                HStack(spacing: AppSpacing.lg) {
                                    OBIcon(name: pillar.icon, size: 28)
                                        .foregroundStyle(OnboardingTheme.accent)
                                        .frame(width: 52, height: 52)
                                        .background(OnboardingTheme.accent.opacity(0.10), in: .circle)
                                    Text(pillar.label)
                                        .appFont(.bodyL)
                                        .fontWeight(.medium)
                                        .foregroundStyle(OnboardingTheme.title)
                                    Spacer()
                                }
                                .padding(AppSpacing.lg)
                                .background(OnboardingTheme.card, in: .rect(cornerRadius: OnboardingTheme.cardCornerRadius))
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
                            }
                        }

                        Text("Your messages are encrypted end to end. Only the people you choose will ever read or watch them.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, AppSpacing.lg)
                }
                .scrollIndicators(.hidden)

                OBBottomBar(title: "Continue") { state.advance(from: .authority) }
            }
        }
    }
}

// MARK: - Act 5: who it's for

struct OBAudienceView: View {
    @Environment(OnboardingState.self) private var state

    private let groups: [(icon: String, title: String, detail: String)] = [
        ("ob-baby", "Parents & children", "Words for the people you're raising, today and for the years ahead."),
        ("ob-heart", "Living with illness", "Be there for the birthdays and milestones you might miss."),
        ("ob-medal", "Military & first responders", "For those whose service carries real, daily risk."),
        ("ob-hardhat", "High-risk work", "If the unexpected happens, your words still reach them.")
    ]

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Image("ob-sky-audience")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        OBTitle(
                            text: "Made for the moments that matter most.",
                            subtitle: "Especially for people who carry more than most.",
                            alignment: .center
                        )

                        VStack(spacing: AppSpacing.md) {
                            ForEach(groups, id: \.title) { g in
                                HStack(alignment: .top, spacing: AppSpacing.lg) {
                                    OBIcon(name: g.icon, size: 26)
                                        .foregroundStyle(OnboardingTheme.accent)
                                        .frame(width: 50, height: 50)
                                        .background(OnboardingTheme.accent.opacity(0.10), in: .circle)
                                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                        Text(g.title)
                                            .appFont(.heading5)
                                            .foregroundStyle(OnboardingTheme.title)
                                        Text(g.detail)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(AppSpacing.lg)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(OnboardingTheme.card, in: .rect(cornerRadius: OnboardingTheme.cardCornerRadius))
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, AppSpacing.lg)
                }
                .scrollIndicators(.hidden)

                OBBottomBar(title: "Continue") { state.advance(from: .audience) }
            }
        }
    }
}

// MARK: - Act 5: science carousel

struct OBScienceView: View {
    @Environment(OnboardingState.self) private var state
    @State private var page = 0

    private static let skyBottom = Color(red: 200/255, green: 222/255, blue: 240/255)

    private let cards = [
        (title: "Letters to the future\nchange behavior.",
         body: "People who write to their future selves make different choices today. The act of speaking forward changes the speaker.",
         image: "ob-sky-science1"),
        (title: "A recorded voice carries\nmore than words.",
         body: "Tone, breath, a pause, a laugh. Hearing someone is one of the deepest comforts after loss, in ways text never reaches.",
         image: "ob-sky-science2"),
        (title: "Closure isn't about\nthe other person.",
         body: "It's about giving the part of you that still has something to say a way to say it. Even years later. Even after.",
         image: "ob-sky-science3")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed background that crossfades as the page changes.
            GeometryReader { proxy in
                Image(cards[page].image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .id(page)
                    .transition(.opacity)
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Self.skyBottom.opacity(0.5), Self.skyBottom.opacity(0.95)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.md) {
                    Text(cards[page].title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentTransition(.numericText())
                    Text(cards[page].body)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentTransition(.numericText())
                }

                HStack(spacing: AppSpacing.sm) {
                    ForEach(cards.indices, id: \.self) { i in
                        Capsule()
                            .fill(OnboardingTheme.title.opacity(i == page ? 0.9 : 0.25))
                            .frame(width: i == page ? 22 : 7, height: 7)
                    }
                }

                Button(page == cards.count - 1 ? "Continue" : "Next") {
                    if page == cards.count - 1 {
                        state.advance(from: .science)
                    } else {
                        withAnimation(.easeInOut(duration: 0.45)) { page += 1 }
                    }
                }
                .primaryButton()
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
        }
        .contentShape(.rect)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width < -40, page < cards.count - 1 {
                        withAnimation(.easeInOut(duration: 0.45)) { page += 1 }
                    } else if value.translation.width > 40, page > 0 {
                        withAnimation(.easeInOut(duration: 0.45)) { page -= 1 }
                    }
                }
        )
    }
}

// MARK: - Act 5: Critical Timed Message intro

struct OBCTMIntroView: View {
    @Environment(OnboardingState.self) private var state

    private let steps: [(icon: String, title: String, detail: String)] = [
        ("ob-calendar", "We check in, gently", "A quiet tap on your schedule. One touch to confirm you're here."),
        ("ob-clock", "If you ever go quiet", "Miss enough check-ins and we know something has changed."),
        ("ob-envelope", "Your message is delivered", "It reaches the person you trusted it to, exactly as you left it.")
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

                OBBottomBar(title: "See what's inside", enabled: stepsDone) {
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
                            Circle().fill(OnboardingTheme.accent.opacity(0.12))
                            OBIcon(name: steps[i].icon, size: 26)
                                .foregroundStyle(OnboardingTheme.accent)
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
