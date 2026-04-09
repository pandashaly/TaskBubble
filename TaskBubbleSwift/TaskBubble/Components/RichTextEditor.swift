import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont = .systemFont(ofSize: 12)
    var textColor: NSColor = .labelColor
    var backgroundColor: NSColor = .clear
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = false // Keep it plain text to avoid formatting issues
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.font = font
        textView.textColor = textColor
        textView.backgroundColor = backgroundColor
        textView.drawsBackground = false
        textView.autoresizingMask = [.width]
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.string = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
        
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // Handle Enter key for auto-bullets/numbering
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                let string = textView.string as NSString
                let selectedRange = textView.selectedRange()
                
                // Find the current line
                let lineRange = string.lineRange(for: NSMakeRange(selectedRange.location, 0))
                let currentLine = string.substring(with: lineRange)
                
                // Check for bullet point "- "
                if currentLine.hasPrefix("- ") {
                    if currentLine.trimmingCharacters(in: .whitespacesAndNewlines) == "-" {
                        // If line is just "-", clear it (user wants to stop bulleting)
                        textView.insertText("", replacementRange: lineRange)
                        return true
                    }
                    textView.insertNewline(nil)
                    textView.insertText("- ", replacementRange: textView.selectedRange())
                    return true
                }
                
                // Check for numbered list "1. "
                let pattern = "^(\\d+)\\.\\s"
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: currentLine, range: NSRange(location: 0, length: currentLine.utf16.count)) {
                    
                    let numberStr = (currentLine as NSString).substring(with: match.range(at: 1))
                    if let number = Int(numberStr) {
                        if currentLine.trimmingCharacters(in: .whitespacesAndNewlines) == "\(number)." {
                            // Clear if empty number line
                            textView.insertText("", replacementRange: lineRange)
                            return true
                        }
                        textView.insertNewline(nil)
                        textView.insertText("\(number + 1). ", replacementRange: textView.selectedRange())
                        return true
                    }
                }
            }
            return false
        }
    }
}
