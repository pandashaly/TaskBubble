import SwiftUI
import AppKit

// MARK: - RichTextFormat
enum RichTextFormat {
    case bold, italic, underline, strikethrough, code
}

// MARK: - RichTextCoordinator
final class RichTextCoordinator: NSObject, NSTextViewDelegate, ObservableObject {

    weak var textView: NSTextView?
    var onTextChange: ((String) -> Void)?

    func applyFormat(_ format: RichTextFormat) {
        guard let tv = textView else { return }

        let range = tv.selectedRange()
        guard range.length > 0 else { return }

        switch format {
        case .bold:
            toggleTrait(.boldFontMask, in: range, textView: tv)

        case .italic:
            toggleTrait(.italicFontMask, in: range, textView: tv)

        case .underline:
            toggleUnderline(in: range, textView: tv)

        case .strikethrough:
            toggleStrikethrough(in: range, textView: tv)

        case .code:
            applyCode(in: range, textView: tv)
        }
    }

    private func toggleTrait(_ trait: NSFontTraitMask, in range: NSRange, textView: NSTextView) {
        guard let storage = textView.textStorage else { return }

        storage.beginEditing()

        storage.enumerateAttribute(.font, in: range) { value, subRange, _ in
            let current = (value as? NSFont) ?? NSFont.systemFont(ofSize: 12)

            let manager = NSFontManager.shared
            let hasTrait = manager.traits(of: current).contains(trait)

            let converted = hasTrait
                ? manager.convert(current, toNotHaveTrait: trait)
                : manager.convert(current, toHaveTrait: trait)

            storage.addAttribute(.font, value: converted, range: subRange)
        }

        storage.endEditing()
    }

    private func toggleUnderline(in range: NSRange, textView: NSTextView) {
        guard let storage = textView.textStorage else { return }

        let existing = storage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int ?? 0

        storage.addAttribute(
            .underlineStyle,
            value: existing == 0 ? NSUnderlineStyle.single.rawValue : 0,
            range: range
        )
    }

    private func toggleStrikethrough(in range: NSRange, textView: NSTextView) {
        guard let storage = textView.textStorage else { return }

        let existing = storage.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) as? Int ?? 0

        storage.addAttribute(
            .strikethroughStyle,
            value: existing == 0 ? NSUnderlineStyle.single.rawValue : 0,
            range: range
        )
    }

    private func applyCode(in range: NSRange, textView: NSTextView) {
        guard let storage = textView.textStorage else { return }

        let currentFont = storage.attribute(.font, at: range.location, effectiveRange: nil) as? NSFont
        let isCode = currentFont?.fontName.contains("Menlo") ?? false

        let newFont: NSFont = isCode
            ? NSFont.systemFont(ofSize: 12)
            : NSFont(name: "Menlo-Regular", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)

        let bgColor: NSColor = isCode
            ? .clear
            : NSColor(calibratedWhite: 0.18, alpha: 1)

        storage.addAttribute(.font, value: newFont, range: range)
        storage.addAttribute(.backgroundColor, value: bgColor, range: range)
    }

    func textDidChange(_ notification: Notification) {
        guard let tv = notification.object as? NSTextView else { return }
        onTextChange?(tv.string)
    }
}

// MARK: - RichTextEditor
struct RichTextEditor: NSViewRepresentable {

    @Binding var text: String

    var font: NSFont = NSFont(name: "Montserrat-Regular", size: 12) ?? NSFont.systemFont(ofSize: 12)

    // light gray instead of white
    var textColor: NSColor = NSColor(calibratedWhite: 0.82, alpha: 1)

    var backgroundColor: NSColor = .clear

    var richText: Bool = false

    var sharedCoordinator: RichTextCoordinator? = nil

    func makeCoordinator() -> RichTextCoordinator {
        let coord = sharedCoordinator ?? RichTextCoordinator()

        coord.onTextChange = { newText in
            text = newText
        }

        return coord
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()

        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        let textView = NSTextView()

        textView.delegate = context.coordinator
        context.coordinator.textView = textView

        textView.isRichText = richText
        textView.allowsUndo = true

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

        textView.font = font
        textView.textColor = textColor
        textView.backgroundColor = backgroundColor

        textView.drawsBackground = false
        textView.isEditable = true
        textView.isSelectable = true

        textView.textContainerInset = NSSize(width: 4, height: 6)

        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }

        context.coordinator.textView = textView

        if textView.string != text {
            textView.string = text
        }
    }
}
