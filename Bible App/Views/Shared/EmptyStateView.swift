//
//  EmptyStateView.swift
//  Bible App
//

import SwiftUI

/// A reusable empty state view with icon, title, message, and optional action button.
/// Follows Apple HIG guidelines for clarity and visual hierarchy.
/// Respects Reduce Motion accessibility setting.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)?
    var actionLabel: String?
    
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Decorative Icon Container
            ZStack {
                Circle()
                    .fill(Color.accentGold.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(Color.accentGold.opacity(0.6))
            }
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0.0)
            .accessibilityHidden(true)
            
            // MARK: - Title
            Text(title)
                .font(AppTheme.heading)
                .foregroundStyle(Color.primaryText)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1.0 : 0.0)
            
            // MARK: - Message
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, AppTheme.sectionGap)
                .opacity(appeared ? 1.0 : 0.0)
            
            // MARK: - Optional Action Button
            if let action, let actionLabel {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Text(actionLabel)
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.accentGold)
                    )
                }
                .frame(minWidth: AppTheme.minTouchTarget, minHeight: AppTheme.minTouchTarget)
                .padding(.top, 8)
                .opacity(appeared ? 1.0 : 0.0)
                .accessibilityLabel(actionLabel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Respect Reduce Motion setting
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension EmptyStateView {
    /// Empty state for favorites
    static var favorites: EmptyStateView {
        EmptyStateView(
            icon: "heart.text.square",
            title: "No favorites yet",
            message: "Tap the ♥ on any verse to save it here\nfor quick access later"
        )
    }
    
    /// Empty state for search with retry action
    static func searchError(message: String, retryAction: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Verse not found",
            message: message,
            action: retryAction,
            actionLabel: "Try again"
        )
    }
    
    /// Empty state for offline
    static var offline: EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "You're offline",
            message: "Connect to the internet to load verses.\nYour favorites are still available."
        )
    }
    
    /// Empty state for general errors
    static func error(message: String, retryAction: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Something went wrong",
            message: message,
            action: retryAction,
            actionLabel: "Try again"
        )
    }
}

// MARK: - Preview

#Preview("Default") {
    EmptyStateView(
        icon: "heart.text.square",
        title: "No favorites yet",
        message: "Tap the ♥ on any verse to save it here\nfor quick access later"
    )
}

#Preview("With Action") {
    EmptyStateView(
        icon: "magnifyingglass",
        title: "No results found",
        message: "We couldn't find any verses matching your search.",
        action: { print("Retry tapped") },
        actionLabel: "Try again"
    )
}

#Preview("Offline") {
    EmptyStateView.offline
}

#Preview("Favorites") {
    EmptyStateView.favorites
}
