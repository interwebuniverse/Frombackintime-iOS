//
//  OBFeatureSteps.swift
//  FromBackInTime
//
//  Act 6. Feature reveals. One reusable layout, fed different content, so
//  the six features feel like a family without being identical: each leads
//  with a labeled app mockup, a title, a subtitle, and feature chips.
//

import SwiftUI

struct OBFeatureView: View {
    @Environment(OnboardingState.self) private var state
    let step: OnboardingStep
    let content: OBFeatureContent

    @State private var shown = 0
    @State private var done = false

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

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(content.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(content.subtitle)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingTheme.title.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, AppSpacing.xxl)

                Spacer(minLength: AppSpacing.xxl)

                // Feature items queue in one by one.
                VStack(spacing: AppSpacing.md) {
                    ForEach(content.chips.indices, id: \.self) { i in
                        itemCard(content.chips[i], visible: i < shown)
                    }
                }

                Spacer()

                Button("Continue") { state.advance(from: step) }
                    .primaryButton()
                    .disabled(!done)
                    .opacity(done ? 1 : 0.45)
            }
            .padding(.horizontal, OnboardingTheme.screenPadding)
            .padding(.bottom, OnboardingTheme.bottomPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear(perform: reveal)
    }

    private func itemCard(_ chip: OBChip, visible: Bool) -> some View {
        HStack(spacing: AppSpacing.lg) {
            if chip.illustration.isEmpty {
                OBIcon(name: chip.icon, size: 28)
                    .foregroundStyle(OnboardingTheme.accent)
                    .frame(width: 64, height: 64)
                    .background(OnboardingTheme.accent.opacity(0.10), in: .circle)
            } else {
                Image(chip.illustration)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 68, height: 68)
            }
            Text(chip.label)
                .appFont(.heading5)
                .foregroundStyle(OnboardingTheme.title)
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: .rect(cornerRadius: OnboardingTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius)
                .strokeBorder(OnboardingTheme.title.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 6)
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 16)
    }

    private func reveal() {
        shown = 0
        done = false
        let chips = content.chips
        for i in chips.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.4) {
                Haptics.feedback(style: .soft)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.62)) { shown = i + 1 }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(chips.count) * 0.4 + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) { done = true }
        }
    }
}

// MARK: - Chip row

struct OBChipRow: View {
    let chips: [OBChip]

    var body: some View {
        FlexibleChips(chips: chips)
    }
}

/// Wrapping chip layout. Each chip is an icon + label so the page reads
/// visually, not as a list of words.
struct FlexibleChips: View {
    let chips: [OBChip]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(rows(), id: \.self) { row in
                HStack(spacing: AppSpacing.sm) {
                    ForEach(row, id: \.self) { chip in
                        chipView(chip)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func chipView(_ chip: OBChip) -> some View {
        HStack(spacing: AppSpacing.sm) {
            OBIcon(name: chip.icon, size: 18)
                .foregroundStyle(OnboardingTheme.accent)
            Text(chip.label)
                .appFont(.labelL)
                .fontWeight(.medium)
                .foregroundStyle(OnboardingTheme.title)
        }
        .padding(.leading, AppSpacing.md)
        .padding(.trailing, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm + 2)
        .background(OnboardingTheme.card, in: .capsule)
        .overlay(Capsule().strokeBorder(OnboardingTheme.accent.opacity(0.15), lineWidth: 1))
    }

    /// Split chips into rows of at most two so long labels never overflow.
    private func rows() -> [[OBChip]] {
        stride(from: 0, to: chips.count, by: 2).map {
            Array(chips[$0..<min($0 + 2, chips.count)])
        }
    }
}
