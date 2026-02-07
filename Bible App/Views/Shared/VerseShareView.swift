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
        VStack(spacing: 24) {
            Spacer()

            // Decorative cross icon
            Image(systemName: "book.closed.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.6))

            // Opening decorative quote mark
            Text("\u{201C}")
                .font(.system(size: 64, design: .serif))
                .foregroundStyle(.white.opacity(0.2))
                .frame(height: 40)

            // Verse text
            Text(response.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 28, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 40)

            // Closing decorative quote mark
            Text("\u{201D}")
                .font(.system(size: 64, design: .serif))
                .foregroundStyle(.white.opacity(0.2))
                .frame(height: 40)

            // Subtle divider
            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 60, height: 1)
                .padding(.vertical, 4)

            // Reference
            Text("— \(response.reference)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))

            // Translation
            Text(response.translationName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))

            Spacer()

            // App branding
            Text("Bible App")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
                .padding(.bottom, 24)
        }
        .frame(width: 1080, height: 1080)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#2C1810"),
                    Color(hex: "#4A2E1C"),
                    Color(hex: "#6B4226")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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
