//
//  ActionButtonView.swift
//  Bible App
//

import SwiftUI

/// A circular action button with proper touch targets and visual feedback.
/// Follows Apple HIG guidelines for 44x44pt minimum touch targets.
struct ActionButtonView: View {
    let icon: String
    let isActive: Bool
    let activeColor: Color
    let inactiveColor: Color
    let accessibilityLabel: String
    let accessibilityHint: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        icon: String,
        isActive: Bool = false,
        activeColor: Color = .red,
        inactiveColor: Color = Color.secondaryText,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.isActive = isActive
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background circle for visual feedback
                Circle()
                    .fill(backgroundColor)
                    .frame(width: AppTheme.minTouchTarget, height: AppTheme.minTouchTarget)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .symbolEffect(.bounce, value: isActive)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
    
    private var backgroundColor: Color {
        if isActive {
            return activeColor.opacity(0.15)
        }
        return Color.secondary.opacity(isPressed ? 0.15 : 0.08)
    }
    
    private var iconColor: Color {
        isActive ? activeColor : inactiveColor
    }
}

// MARK: - Pressable Button Style

/// A button style that tracks pressed state for visual feedback
struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Convenience Initializers

extension ActionButtonView {
    /// Favorite button with heart icon
    static func favorite(
        isFavorited: Bool,
        action: @escaping () -> Void
    ) -> ActionButtonView {
        ActionButtonView(
            icon: isFavorited ? "heart.fill" : "heart",
            isActive: isFavorited,
            activeColor: .red,
            accessibilityLabel: isFavorited ? "Remove from favorites" : "Add to favorites",
            accessibilityHint: isFavorited
                ? "Double-tap to remove this verse from your favorites"
                : "Double-tap to save this verse to your favorites",
            action: action
        )
    }
    
    /// Share button
    static func share(action: @escaping () -> Void) -> ActionButtonView {
        ActionButtonView(
            icon: "square.and.arrow.up",
            inactiveColor: Color.secondaryText,
            accessibilityLabel: "Share verse",
            accessibilityHint: "Double-tap to share this verse",
            action: action
        )
    }
    
    /// Delete/remove button
    static func delete(action: @escaping () -> Void) -> ActionButtonView {
        ActionButtonView(
            icon: "heart.slash",
            isActive: false,
            activeColor: .red,
            inactiveColor: .red,
            accessibilityLabel: "Remove from favorites",
            accessibilityHint: "Double-tap to remove this verse from your favorites",
            action: action
        )
    }
}

// MARK: - Action Buttons Container

/// A horizontal container for verse action buttons with proper spacing
struct ActionButtonsContainer: View {
    let isFavorited: Bool
    let onFavoriteToggle: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.sectionGap) {
            ActionButtonView.favorite(
                isFavorited: isFavorited,
                action: onFavoriteToggle
            )
            
            ActionButtonView.share(action: onShare)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview("Action Buttons") {
    VStack(spacing: 40) {
        ActionButtonView.favorite(isFavorited: false) { }
        ActionButtonView.favorite(isFavorited: true) { }
        ActionButtonView.share { }
        ActionButtonView.delete { }
        
        ActionButtonsContainer(
            isFavorited: false,
            onFavoriteToggle: { },
            onShare: { }
        )
        
        ActionButtonsContainer(
            isFavorited: true,
            onFavoriteToggle: { },
            onShare: { }
        )
    }
    .padding()
}
