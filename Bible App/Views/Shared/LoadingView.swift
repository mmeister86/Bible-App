//
//  LoadingView.swift
//  Bible App
//

import SwiftUI

/// An elegant loading indicator with an animated message and subtle scale pulse.
/// Can optionally show a skeleton view for verse content.
struct LoadingView: View {
    var message: String = "Loading verse..."
    var showSkeleton: Bool = false

    @State private var opacity: Double = 0.4
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            if showSkeleton {
                VerseSkeletonView()
                    .padding(.horizontal, AppTheme.screenMargin)
            } else {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.accentGold)
                    .accessibilityLabel("Loading")

                Text(message)
                    .font(AppTheme.reference)
                    .foregroundStyle(Color.secondaryText)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            opacity = 1.0
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(appeared ? 1.0 : 0.0)
        .scaleEffect(appeared ? 1.0 : 0.95)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
    }
}

#Preview("Default") {
    LoadingView()
}

#Preview("With Skeleton") {
    LoadingView(message: "Loading verse...", showSkeleton: true)
}
