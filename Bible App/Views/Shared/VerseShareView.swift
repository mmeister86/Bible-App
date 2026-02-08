//
//  VerseShareView.swift
//  Bible App
//

import SwiftUI

/// A non-interactive rendered version of a verse card designed for sharing.
/// Uses `ImageRenderer` (iOS 16+) to produce a `UIImage` suitable for social media.
/// Features decorative quotation marks and a refined visual design.
struct VerseShareView: View {
    let response: BibleResponse

    var body: some View {
        ZStack {
            // Warm cream base
            Color(hex: "#FFFDF7")

            // Subtle center glow for depth
            RadialGradient(
                colors: [.white.opacity(0.3), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 540
            )

            // Content
            VStack(spacing: 20) {
                Spacer()

                // Decorative opening quote — gold accent
                Text("\u{201C}")
                    .font(.system(size: 120, design: .serif))
                    .foregroundStyle(Color(hex: "#C9953C").opacity(0.25))
                    .frame(height: 60)

                // Verse text — maximum contrast
                Text(response.text.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(size: 36, design: .serif))
                    .foregroundStyle(Color(hex: "#1A1A1A"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 64)

                // Gold divider
                Rectangle()
                    .fill(Color(hex: "#C9953C").opacity(0.6))
                    .frame(width: 58, height: 1.5)
                    .padding(.vertical, 8)

                // Reference — gold accent
                Text("— \(response.reference)")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(hex: "#C9953C"))

                // Translation name — subtle, letter-spaced
                Text(response.translationName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: "#8A8A8A"))
                    .tracking(0.5)

                Spacer()

                // Branding
                HStack(spacing: 6) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 12))
                    Text("Bible App")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(Color(hex: "#B0A89A"))
                .padding(.bottom, 40)
            }
        }
        // Gold border frame
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#C9953C").opacity(0.4), lineWidth: 1.5)
                .padding(36)
        }
        .frame(width: 1080, height: 1080)
    }

    // MARK: - Render to UIImage

    /// Renders this view to a `UIImage` using `ImageRenderer`.
    @MainActor
    static func renderImage(for response: BibleResponse) -> UIImage? {
        let view = VerseShareView(response: response)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0 // higher resolution
        return renderer.uiImage
    }
}

#Preview {
    VerseShareView(
        response: BibleResponse(
            reference: "John 3:16",
            verses: [
                VerseEntry(
                    bookId: "JHN",
                    bookName: "John",
                    chapter: 3,
                    verse: 16,
                    text: "For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.\n"
                )
            ],
            text: "For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.\n",
            translationId: "web",
            translationName: "World English Bible",
            translationNote: "Public Domain"
        )
    )
    .previewLayout(.sizeThatFits)
}
