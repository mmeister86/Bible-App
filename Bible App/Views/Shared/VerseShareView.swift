//
//  VerseShareView.swift
//  Bible App
//

import SwiftUI
import UIKit
import os

/// A non-interactive rendered version of a verse card designed for sharing.
/// Uses `ImageRenderer` (iOS 16+) to produce a `UIImage` suitable for social media.
/// Features decorative quotation marks and a refined visual design.
struct VerseShareView: View {
    let response: BibleResponse
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "BibleApp", category: "VerseShare")

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

    // MARK: - Image Cache

    /// Cache for rendered share images to avoid expensive re-rendering
    /// Uses NSCache which automatically handles memory pressure
    private static let imageCache = NSCache<NSString, UIImage>()

    /// Renders this view to a `UIImage` using `ImageRenderer`.
    /// Results are cached by verse reference AND translation to avoid stale images.
    @MainActor
    static func renderImage(for response: BibleResponse) -> UIImage? {
        let cacheKey = "\(response.translationId)_\(response.reference)" as NSString
        
        // Check cache first
        if let cached = imageCache.object(forKey: cacheKey) {
            logger.debug("Share image cache hit for \(response.reference, privacy: .public)")
            return cached
        }
        logger.debug("Share image cache miss for \(response.reference, privacy: .public); rendering fallback")
        
        // Render if not cached
        let view = VerseShareView(response: response)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0 // higher resolution
        
        if let image = renderer.uiImage {
            // Store in cache
            imageCache.setObject(image, forKey: cacheKey)
            logger.debug("Rendered and cached share image for \(response.reference, privacy: .public)")
            return image
        }

        logger.error("Failed to render share image for \(response.reference, privacy: .public)")
        
        return nil
    }

    /// Returns cached image without rendering - returns nil if not cached
    /// Use this for share sheets where the image may have been pre-rendered
    static func cachedImage(for response: BibleResponse) -> UIImage? {
        let cacheKey = "\(response.translationId)_\(response.reference)" as NSString
        return imageCache.object(forKey: cacheKey)
    }

    /// Pre-renders and caches an image for future use
    /// Call this when verse is displayed to prepare for sharing
    @MainActor
    static func preRender(for response: BibleResponse) {
        let cacheKey = "\(response.translationId)_\(response.reference)" as NSString
        
        // Skip if already cached
        if imageCache.object(forKey: cacheKey) != nil {
            logger.debug("Skipped pre-render; cache already populated for \(response.reference, privacy: .public)")
            return
        }
        
        let view = VerseShareView(response: response)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        
        if let image = renderer.uiImage {
            imageCache.setObject(image, forKey: cacheKey)
            logger.debug("Pre-rendered share image for \(response.reference, privacy: .public)")
            return
        }

        logger.error("Pre-render failed for \(response.reference, privacy: .public)")
    }

    /// Clears the image cache (useful for memory warnings)
    static func clearCache() {
        imageCache.removeAllObjects()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
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
}
