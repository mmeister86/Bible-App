//
//  SwipeToDeleteModifier.swift
//  Bible App
//

import SwiftUI

/// A reusable swipe-to-delete modifier for views inside a ScrollView.
/// Swipe right-to-left to reveal a red delete background. Exceeding the
/// threshold (or swiping fast enough) triggers the delete callback;
/// otherwise the row snaps back with a spring animation.
private struct SwipeToDeleteModifier: ViewModifier {
    let onDelete: () -> Void

    private let deleteThreshold: CGFloat = 120
    private let velocityThreshold: CGFloat = 300

    @State private var offset: CGFloat = 0
    @GestureState private var isDragging = false

    /// Progress toward the delete threshold, clamped to 0...1.
    private var progress: CGFloat {
        min(abs(offset) / deleteThreshold, 1)
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            // Delete background revealed behind the row
            deleteBackground
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))

            // The actual row content, shifted by the drag offset
            content
                .offset(x: offset)
        }
        .simultaneousGesture(swipeGesture)
        .onChange(of: isDragging) { _, dragging in
            // When gesture is cancelled (e.g. finger moves out of bounds),
            // GestureState auto-resets isDragging to false — snap back.
            if !dragging && offset != 0 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = 0
                }
            }
        }
        .accessibilityAction(named: "Remove from favorites") {
            onDelete()
        }
    }

    // MARK: - Delete Background

    private var deleteBackground: some View {
        HStack {
            Spacer()
            Image(systemName: "trash")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .opacity(Double(progress))
                .scaleEffect(0.7 + 0.3 * progress)
                .padding(.trailing, AppTheme.cardPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red.opacity(0.2 + 0.8 * Double(progress)))
    }

    // MARK: - Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                let dx = value.translation.width
                let dy = value.translation.height

                // Only handle horizontal right-to-left swipes
                guard dx < 0, abs(dx) > abs(dy) * 2 else { return }

                // Apply rubber-banding past the threshold
                if abs(dx) > deleteThreshold {
                    let excess = abs(dx) - deleteThreshold
                    offset = -deleteThreshold - excess * 0.3
                } else {
                    offset = dx
                }
            }
            .onEnded { value in
                let dx = value.translation.width
                let predictedDx = value.predictedEndTranslation.width

                // Trigger delete if past threshold or if velocity is high enough
                let pastThreshold = abs(dx) > deleteThreshold
                let fastSwipe = abs(predictedDx) > velocityThreshold && dx < 0

                if pastThreshold || fastSwipe {
                    // Animate row off-screen, then delete
                    withAnimation(.easeIn(duration: 0.2)) {
                        offset = -500
                    }
                    // Fire delete after the animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDelete()
                    }
                } else {
                    // Snap back
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                    }
                }
            }
    }
}

extension View {
    /// Adds a right-to-left swipe gesture that reveals a delete action.
    func swipeToDelete(perform action: @escaping () -> Void) -> some View {
        modifier(SwipeToDeleteModifier(onDelete: action))
    }
}
