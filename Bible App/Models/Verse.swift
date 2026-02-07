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

    enum CodingKeys: String, CodingKey {
        case bookId = "book_id"
        case bookName = "book_name"
        case chapter
        case verse
        case text
    }
}
