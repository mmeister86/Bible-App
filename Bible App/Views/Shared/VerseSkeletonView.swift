//
//  VerseSkeletonView.swift
//  Bible App
//

import SwiftUI

/// A skeleton loading view that mimics the VerseCardView layout
/// with shimmer animation for a polished loading experience.
/// Respects Reduce Motion accessibility setting.
struct VerseSkeletonView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false
    
    var body: some View {
        skeletonContent
            .padding(AppTheme.cardPadding)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .shadow(
                color: AppTheme.cardShadowColor,
                radius: AppTheme.cardShadowRadius,
                x: 0,
                y: AppTheme.cardShadowY
            )
            // Apply shimmer only if Reduce Motion is not enabled
            .modifier(ConditionalShimmerModifier(shouldApply: !reduceMotion, isAnimating: isAnimating))
            .onAppear {
                isAnimating = true
            }
            .accessibilityLabel("Loading verse")
    }
    
    @ViewBuilder
    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Decorative Opening Quote Skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(skeletonColor)
                .frame(width: 40, height: 40)
                .offset(x: -4)
            
            // MARK: - Verse Text Lines Skeleton
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(skeletonColor)
                        .frame(height: 16)
                        .frame(maxWidth: index == 3 ? 180 : .infinity)
                }
            }
            
            // MARK: - Closing Quote Skeleton
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(skeletonColor)
                    .frame(width: 40, height: 32)
                    .offset(x: 4)
            }
            
            // MARK: - Divider Skeleton
            RoundedRectangle(cornerRadius: 1)
                .fill(skeletonColor)
                .frame(height: 1)
                .padding(.vertical, 4)
            
            // MARK: - Reference Skeleton
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(skeletonColor)
                    .frame(width: 120, height: 16)
                
                // Translation badge skeleton
                RoundedRectangle(cornerRadius: 12)
                    .fill(skeletonColor)
                    .frame(width: 100, height: 24)
            }
        }
    }
    
    private var skeletonColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.1)
            : Color.black.opacity(0.06)
    }
}

// MARK: - Conditional Shimmer Modifier

/// A view modifier that conditionally applies shimmer based on a flag
struct ConditionalShimmerModifier: ViewModifier {
    let shouldApply: Bool
    let isAnimating: Bool
    
    func body(content: Content) -> some View {
        if shouldApply {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.3),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width / 3)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width / 3)
                        .animation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        } else {
            content
        }
    }
}

// MARK: - Shimmer Modifier (for direct use)

extension View {
    /// Applies a shimmer effect to the view
    func shimmer(isAnimating: Bool) -> some View {
        self.modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

/// A view modifier that adds a shimmer animation effect
struct ShimmerModifier: ViewModifier {
    let isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width / 3)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width / 3)
                    .animation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }
}

// MARK: - Preview

#Preview("Skeleton - Light Mode") {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        VerseSkeletonView()
            .padding(AppTheme.screenMargin)
    }
}

#Preview("Skeleton - Dark Mode") {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        
        VerseSkeletonView()
            .padding(AppTheme.screenMargin)
    }
    .preferredColorScheme(.dark)
}
