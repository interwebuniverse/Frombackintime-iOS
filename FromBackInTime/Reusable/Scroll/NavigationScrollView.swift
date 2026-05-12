//
//  NavigationScrollView.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

struct NavigationScrollView<Content: View>: View {
    let id = UUID()
    
    let title: String
    var subtitle: String? = nil
    var back: (() -> Void)? = nil
    var dismiss: (() -> Void)? = nil
    @ViewBuilder let content: Content
    
    @State private var compactAppearance = false
    @State private var scrollTitleHeight = CGFloat.zero
    @State private var scrollHeaderHeight = CGFloat.zero
    @State private var scrollTitleFontSize = CGFloat(28)
    
    var body: some View {
        VStack(spacing: .zero) {
            header
            
            ScrollView {
                VStack(spacing: .zero) {
                    scrollHeader
                    
                    ZStack {
                        content
                    }
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        return proxy.frame(in: .scrollView).minY
                    } action: { newValue in
                        Execute.async {
                            let offset = (newValue - scrollHeaderHeight)
                            compactAppearance = offset < -scrollTitleHeight
                            let font = max(28, min(36, 28 + (offset / 20)))
                            scrollTitleFontSize = font
                        }
                    }
                }
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: .zero) {
            if let back {
                Button(action: back) {
//                    Image(.commonBack)
                }
            }
            
            Spacer()
            
            if let dismiss {
                Button(action: dismiss) {
//                    Image(.commonDismiss)
                }
            }
        }
        .padding(.horizontal, 32)
        .frame(height: 64)
        .overlay {
            ZStack {
                if compactAppearance {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(minHeight: 24)
                        .transition(.move(edge: .bottom).combined(with: .blurReplace))
                }
            }
            .animation(.bouncy(duration: 0.3), value: compactAppearance)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.white.opacity(compactAppearance ? 0.1 : 0))
                .animation(.easeInOut(duration: 0.3), value: compactAppearance)
        }
    }
    
    private var scrollHeader: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: scrollTitleFontSize, weight: .bold))
                .foregroundStyle(.white)
                .frame(minHeight: 36)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .lineLimit(1)
                .onGeometryChange(for: CGSize.self) { proxy in
                    return proxy.frame(in: .global).size
                } action: { newValue in
                    Execute.async {
                        scrollTitleHeight = newValue.height
                    }
                }
                .opacity(compactAppearance ? 0 : 1)
                .blur(radius: compactAppearance ? 5 : 0)
                .offset(y: compactAppearance ? -3 : 0)
                .animation(.bouncy(duration: 0.3), value: compactAppearance)
            
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(minHeight: 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.vertical, 16)
        .onGeometryChange(for: CGSize.self) { proxy in
            return proxy.frame(in: .global).size
        } action: { newValue in
            Execute.async {
                scrollHeaderHeight = newValue.height
            }
        }
    }
}

#Preview {
    NavigationScrollView(title: "Account", subtitle: "Compare original and upscaled versions") {
        VStack(spacing: .zero) {
            Rectangle()
                .foregroundStyle(.white.opacity(0.05))
                .frame(height: 500)
            
            Rectangle()
                .foregroundStyle(.white.opacity(0.05))
                .frame(height: 500)
        }
    }
}
