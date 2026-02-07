//
//  String+Trimming.swift
//  Bible App
//

import Foundation

extension String {
    /// Trims leading/trailing whitespace and newlines, and collapses
    /// multiple consecutive spaces into a single space.
    var trimmedVerse: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
    }
}
