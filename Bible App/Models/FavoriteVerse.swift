//
//  FavoriteVerse.swift
//  Bible App
//

import Foundation
import SwiftData

/// SwiftData model for locally persisted favorite verses
@Model
final class FavoriteVerse {
    var id: UUID
    @Attribute(.unique) var reference: String
    var text: String
    var bookName: String
    var chapter: Int
    var verse: Int
    var translationName: String
    var savedAt: Date

    init(
        id: UUID = UUID(),
        reference: String,
        text: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        translationName: String,
        savedAt: Date = Date()
    ) {
        self.id = id
        self.reference = reference
        self.text = text
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.translationName = translationName
        self.savedAt = savedAt
    }
}
