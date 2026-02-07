//
//  Verse.swift
//  Bible App
//

import Foundation

/// Individual verse entry from the API response
struct VerseEntry: Codable, Equatable, Identifiable {
    let bookId: String
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String

    /// Unique identifier combining book, chapter, and verse
    var id: String { "\(bookId).\(chapter).\(verse)" }
}
