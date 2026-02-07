//
//  ErrorView.swift
//  Bible App
//

import SwiftUI

/// A friendly error state view with icon, message, and retry button.
/// Includes haptic feedback on retry and a gentle appear animation.
struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void

    @State private var appeared = false
    @State private var retryCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentGold)
                .symbolEffect(.pulse, options: .repeating.speed(0.5), value: appeared)

            Text(errorMessage)
                .font(AppTheme.reference)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.screenMargin)

            Button {
                retryCount += 1
                retryAction()
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.accentGold)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
        // Haptic feedback on retry
        .sensoryFeedback(.error, trigger: retryCount)
    }
}

#Preview {
    ErrorView(errorMessage: "No internet connection. Please check your network and try again.") {
        print("Retry tapped")
    }
}
