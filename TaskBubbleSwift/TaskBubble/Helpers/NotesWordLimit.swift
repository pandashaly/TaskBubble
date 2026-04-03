import Foundation

let maxNotesWords = 300

func wordCount(_ text: String) -> Int {
    let parts = text.split { $0.isWhitespace || $0.isNewline }
    return parts.count
}

func clampedNotes(_ text: String) -> String {
    let parts = text.split { $0.isWhitespace || $0.isNewline }
    guard parts.count > maxNotesWords else { return text }
    return parts.prefix(maxNotesWords).joined(separator: " ")
}
