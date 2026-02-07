//
//  BibleResponse.swift
//  Bible App
//

import Foundation

/// API response model from bible-api.com
struct BibleResponse: Codable, Equatable {
    let reference: String
    let verses: [VerseEntry]
    let text: String
    let translationId: String
    let translationName: String
    let translationNote: String
}
