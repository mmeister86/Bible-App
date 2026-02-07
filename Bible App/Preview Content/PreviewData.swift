//
//  PreviewData.swift
//  Bible App
//

import Foundation

/// Mock data for SwiftUI previews and testing.
enum PreviewData {

    /// Sample single-verse response (John 3:16)
    static let sampleResponse = BibleResponse(
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

    /// Sample multi-verse passage (Romans 8:28-29)
    static let sampleMultiVerse = BibleResponse(
        reference: "Romans 8:28-29",
        verses: [
            VerseEntry(
                bookId: "ROM",
                bookName: "Romans",
                chapter: 8,
                verse: 28,
                text: "We know that all things work together for good for those who love God, for those who are called according to his purpose.\n"
            ),
            VerseEntry(
                bookId: "ROM",
                bookName: "Romans",
                chapter: 8,
                verse: 29,
                text: "For whom he foreknew, he also predestined to be conformed to the image of his Son, that he might be the firstborn among many brothers.\n"
            )
        ],
        text: "We know that all things work together for good for those who love God, for those who are called according to his purpose.\nFor whom he foreknew, he also predestined to be conformed to the image of his Son, that he might be the firstborn among many brothers.\n",
        translationId: "web",
        translationName: "World English Bible",
        translationNote: "Public Domain"
    )

    /// Sample Psalm verse
    static let samplePsalm = BibleResponse(
        reference: "Psalm 23:1",
        verses: [
            VerseEntry(
                bookId: "PSA",
                bookName: "Psalms",
                chapter: 23,
                verse: 1,
                text: "The LORD is my shepherd; I shall not want.\n"
            )
        ],
        text: "The LORD is my shepherd; I shall not want.\n",
        translationId: "web",
        translationName: "World English Bible",
        translationNote: "Public Domain"
    )

    /// Sample FavoriteVerse for previews
    static let sampleFavorite = FavoriteVerse(
        reference: "John 3:16",
        text: "For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.",
        bookName: "John",
        chapter: 3,
        verse: 16,
        translationName: "World English Bible"
    )
}
