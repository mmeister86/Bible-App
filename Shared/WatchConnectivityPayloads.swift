//
//  WatchConnectivityPayloads.swift
//  Bible App
//

import Foundation

enum WatchConnectivityPayloadKey {
    static let dailyVerseContext = "watch.dailyVerseContext"
    static let randomVerseRequest = "watch.randomVerseRequest"
    static let randomVerseResponse = "watch.randomVerseResponse"
}

struct DailyVerseTransferPayload: Codable, Equatable {
    let verse: BibleResponse
    let selectedTranslation: String
    let generatedAt: Date
}

struct RandomVerseRequestPayload: Codable, Equatable {
    let requestID: String
    let requestedAt: Date

    init(requestID: String = UUID().uuidString, requestedAt: Date = Date()) {
        self.requestID = requestID
        self.requestedAt = requestedAt
    }
}

struct RandomVerseResponsePayload: Codable, Equatable {
    let requestID: String
    let verse: BibleResponse?
    let selectedTranslation: String
    let generatedAt: Date
    let errorMessage: String?

    var isSuccess: Bool {
        verse != nil && errorMessage == nil
    }
}

enum WatchConnectivityPayloadCoder {
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    static func encode<T: Encodable>(_ value: T) throws -> Data {
        try encoder.encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}
