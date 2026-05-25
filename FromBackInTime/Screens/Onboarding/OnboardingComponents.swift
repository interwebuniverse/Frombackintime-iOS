//
//  OnboardingComponents.swift
//  FromBackInTime
//
//  Reusable building blocks shared across onboarding steps. All styling
//  comes from OnboardingTheme so the look can be retuned in one place.
//

import SwiftUI
import UIKit

// MARK: - Icon
// Bundled phosphor icons (regular weight), imported as template images so
// they tint with foregroundStyle. Use these instead of SF Symbols across
// onboarding so the icon language is consistent.

struct OBIcon: View {
    let name: String
    var size: CGFloat = 24

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

// MARK: - Illustration
// A real generated illustration. The art is rendered on the app cream so it
// sits edge-free on the page: no box, no border, no clip. Falls back to the
// labeled placeholder when the named asset isn't in the catalog yet.

struct OBIllustration: View {
    let name: String
    var description: String = ""
    var height: CGFloat? = nil

    private var exists: Bool { UIImage(named: name) != nil }

    var body: some View {
        if exists {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: height)
        } else {
            OBImagePlaceholder(description: description, height: height)
        }
    }
}

// MARK: - Image placeholder
// Every spot where a real AI illustration will live shows this labeled box
// for now, so the layout and storytelling are reviewable before art exists.

struct OBImagePlaceholder: View {
    let description: String
    var height: CGFloat? = nil
    var cinematic: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius)
            .fill(cinematic ? Color.white.opacity(0.06) : OnboardingTheme.placeholderFill)
            .overlay(
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "photo")
                        .font(.system(size: 22, weight: .regular))
                    Text(description)
                        .appFont(.bodyS)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(cinematic ? OnboardingTheme.onCinematicSubtitle : OnboardingTheme.placeholderText)
                .padding(AppSpacing.lg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius)
                    .strokeBorder(
                        (cinematic ? Color.white.opacity(0.18) : OnboardingTheme.subtitle.opacity(0.4)),
                        style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                    )
            )
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
}

// MARK: - Bounce press style

struct OBBounceStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(OnboardingTheme.bounce, value: configuration.isPressed)
    }
}

extension View {
    func obBounce(scale: CGFloat = 0.96) -> some View {
        buttonStyle(OBBounceStyle(scale: scale))
    }
}

// MARK: - Progress bar

struct OBProgressBar: View {
    let progress: Double   // 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(OnboardingTheme.progressTrack)
                Capsule()
                    .fill(OnboardingTheme.progressFill)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
            }
        }
        .frame(height: 6)
        .animation(OnboardingTheme.questionSwap, value: progress)
    }
}

// MARK: - Choice row (quiz answer)

struct OBChoiceRow: View {
    let emoji: String?
    let text: String
    var reveal: String? = nil   // kept for call-site compatibility; not rendered
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: AppSpacing.md) {
                if let emoji {
                    Text(emoji).font(.system(size: 22))
                }
                Text(text)
                    .appFont(.bodyM)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: AppSpacing.sm)

                // Fixed-size indicator: an empty ring when unselected, a filled
                // check when selected. Both occupy the same frame so selecting
                // never changes the row's height or shifts the layout.
                ZStack {
                    Circle()
                        .strokeBorder(OnboardingTheme.onUnselected.opacity(0.25), lineWidth: 1.5)
                        .opacity(isSelected ? 0 : 1)
                    OBIcon(name: "ob-seal-check", size: 24)
                        .opacity(isSelected ? 1 : 0)
                        .scaleEffect(isSelected ? 1 : 0.4)
                }
                .frame(width: 24, height: 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.lg)
            .background(OnboardingTheme.card, in: .rect(cornerRadius: OnboardingTheme.answerCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: OnboardingTheme.answerCornerRadius)
                    .strokeBorder(OnboardingTheme.title, lineWidth: isSelected ? 2 : 0)
            )
            .foregroundStyle(OnboardingTheme.onUnselected)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 5)
        }
        .obBounce()
        .animation(OnboardingTheme.bounce, value: isSelected)
    }
}

// MARK: - Count-up number (numericText content transition)

struct OBCountUp: View {
    let target: Int
    var prefix: String = ""
    var suffix: String = ""
    var typography: AppTypography = .heading1
    /// When set, overrides typography with an explicit rounded system size.
    var bigSize: CGFloat? = nil
    var bigWeight: Font.Weight = .heavy

    @State private var value = 0

    private var label: Text {
        Text("\(prefix)\(value.formatted(.number.grouping(.automatic)))\(suffix)")
    }

    var body: some View {
        Group {
            if let bigSize {
                label.font(.system(size: bigSize, weight: bigWeight, design: .rounded))
            } else {
                label.appFont(typography)
            }
        }
        .monospacedDigit()
        .contentTransition(.numericText(value: Double(value)))
        .onAppear(perform: start)
    }

    // Roll the number up through intermediate values so it reads like an
    // odometer instead of one large numericText jump (which slid the whole
    // glyph up and looked buggy). Ease-out so it slows as it lands.
    private func start() {
        guard value != target else { return }
        let steps = 24
        let total = OnboardingTheme.countUp
        let stepDuration = total / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                let p = Double(i) / Double(steps)
                let eased = 1 - pow(1 - p, 3)
                withAnimation(.linear(duration: stepDuration)) {
                    value = Int((Double(target) * eased).rounded())
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + total) { value = target }
    }
}

// MARK: - Typing text (typewriter + haptics)
// Statement beats type themselves out one character at a time with a soft
// haptic tick per letter. The final text is laid out invisibly underneath so
// the surrounding layout never reflows while typing.

struct OBTypingText: View {
    let text: String
    var size: CGFloat = 40
    var weight: Font.Weight = .bold
    var color: Color = OnboardingTheme.title
    var onComplete: () -> Void = {}

    var charInterval: TimeInterval = 0.022
    /// Optional substring drawn in the blue highlight color.
    var highlight: String = ""

    @State private var count = 0

    // The full string is always laid out; characters past `count` are drawn
    // clear. Layout never changes, so the reveal can't jump or reflow.
    private var attributed: AttributedString {
        var s = AttributedString(text)
        s.foregroundColor = color
        if !highlight.isEmpty, let r = text.range(of: highlight), let ar = Range(r, in: s) {
            s[ar].foregroundColor = OnboardingTheme.highlight
        }
        if count < text.count {
            let start = s.index(s.startIndex, offsetByCharacters: count)
            s[start...].foregroundColor = .clear
        }
        return s
    }

    var body: some View {
        Text(attributed)
            .font(.system(size: size, weight: weight, design: .rounded))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .contentTransition(.numericText())
            .onAppear(perform: start)
    }

    private func start() {
        count = 0
        let total = text.count
        let chars = Array(text)
        Timer.scheduledTimer(withTimeInterval: charInterval, repeats: true) { timer in
            guard count < total else {
                timer.invalidate()
                onComplete()
                return
            }
            if chars[count] != " " { Haptics.feedback(style: .soft) }
            // Each newly revealed character morphs in with numericText; the
            // full text stays laid out so nothing reflows.
            withAnimation(.snappy(duration: 0.18)) { count += 1 }
        }
    }
}

// MARK: - Bottom CTA bar
// Pinned primary action plus optional text secondary. Reused on most steps.

struct OBBottomBar<Trailing: View>: View {
    let title: String
    var enabled: Bool = true
    var secondaryTitle: String? = nil
    let action: () -> Void
    var secondaryAction: (() -> Void)? = nil
    @ViewBuilder var aboveButton: () -> Trailing

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            aboveButton()

            Button(title, action: action)
                .primaryButton()
                .disabled(!enabled)

            if let secondaryTitle, let secondaryAction {
                Button(secondaryTitle, action: secondaryAction)
                    .textButton()
            }
        }
        .padding(.horizontal, OnboardingTheme.screenPadding)
        .padding(.bottom, OnboardingTheme.bottomPadding)
    }
}

extension OBBottomBar where Trailing == EmptyView {
    init(
        title: String,
        enabled: Bool = true,
        secondaryTitle: String? = nil,
        action: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            enabled: enabled,
            secondaryTitle: secondaryTitle,
            action: action,
            secondaryAction: secondaryAction,
            aboveButton: { EmptyView() }
        )
    }
}

// MARK: - Big in-content title
// Used instead of the system large nav title so it can animate during
// question swaps and on cinematic screens. Native back button still shows.

struct OBTitle: View {
    let text: String
    var subtitle: String? = nil
    var onDark: Bool = false
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: AppSpacing.sm) {
            Text(text)
                .appFont(.heading1)
                .fontWeight(.bold)
                .foregroundStyle(onDark ? OnboardingTheme.onCinematic : OnboardingTheme.title)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.numericText())
            if let subtitle {
                Text(subtitle)
                    .appFont(.bodyM)
                    .foregroundStyle(onDark ? OnboardingTheme.onCinematicSubtitle : OnboardingTheme.subtitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.numericText())
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
        .multilineTextAlignment(alignment == .center ? .center : .leading)
    }
}
