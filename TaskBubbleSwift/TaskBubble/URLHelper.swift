//
//  URLHelper.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//

import Foundation

func normalizedURL(from string: String) -> URL? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
        return URL(string: trimmed)
    } else {
        return URL(string: "https://\(trimmed)")
    }
}
