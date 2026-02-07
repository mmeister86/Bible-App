//
//  BibleAPIClient.swift
//  Bible App
//

import Foundation

/// Errors that can occur when communicating with the Bible API
enum BibleAPIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case httpError(statusCode: Int)
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for the request."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "Server returned HTTP \(statusCode)."
        case .notFound:
            return "Verse not found. Try a reference like John 3:16."
        }
    }
}

/// Stateless API client for bible-api.com
struct BibleAPIClient {

    private static let baseURL = "https://bible-api.com"

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// Fetch a specific verse or passage by reference
    /// - Parameters:
    ///   - reference: Bible reference string (e.g. "John 3:16", "Romans 8:28-30")
    ///   - translation: Translation ID (default: "web")
    /// - Returns: Decoded `BibleResponse`
    static func fetchVerse(
        reference: String,
        translation: String = "web"
    ) async throws -> BibleResponse {
        guard let encodedReference = reference.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) else {
            throw BibleAPIError.invalidURL
        }

        let urlString = "\(baseURL)/\(encodedReference)?translation=\(translation)"

        guard let url = URL(string: urlString) else {
            throw BibleAPIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    /// Fetch a random verse
    /// - Parameter translation: Translation ID (default: "web")
    /// - Returns: Decoded `BibleResponse`
    static func fetchRandomVerse(
        translation: String = "web"
    ) async throws -> BibleResponse {
        let urlString = "\(baseURL)/?random=verse&translation=\(translation)"

        guard let url = URL(string: urlString) else {
            throw BibleAPIError.invalidURL
        }

        return try await performRequest(url: url)
    }

    // MARK: - Private

    private static func performRequest(url: URL) async throws -> BibleResponse {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw BibleAPIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BibleAPIError.networkError(
                URLError(.badServerResponse)
            )
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 404:
            throw BibleAPIError.notFound
        default:
            throw BibleAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try decoder.decode(BibleResponse.self, from: data)
            return decoded
        } catch {
            throw BibleAPIError.decodingError(error)
        }
    }
}
