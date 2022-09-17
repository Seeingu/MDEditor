//
//  MDTextView+NSTextInputClient.swift
//  
//
//  Created by seeu on 2022/9/7.
//

// MARK: - Common

extension MDTextView {
    internal func replaceCharacters(in range: NSTextRange, with string: String) {
        if !isEditable {
            return
        }
        textContentStorage.textStorage?.replaceCharacters(in: convertRange(from: range), with: string)
        let newString = textContentStorage.textStorage!.string
        self.setString(newString)
        textViewDelegate?.onTextChange(string)

        relayout()
    }

    internal func insertString(_ string: String) {
        for textRange in textLayoutManager.textSelections.flatMap(\.textRanges) {
            replaceCharacters(in: textRange, with: string)
        }
    }

    internal func insertString(_ string: String, replacementRange: NSRange) {
        textContentStorage?.performEditingTransaction {
            if let textRange = convertRange(from: replacementRange) {
                replaceCharacters(in: textRange, with: string)
            } else {
                insertText(string)
            }
        }
    }

    internal func delete(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, allowsDecomposition: Bool) {
        let textRanges = textLayoutManager.textSelections.flatMap { textSelection -> [NSTextRange] in
            return textLayoutManager.textSelectionNavigation.deletionRanges(
                for: textSelection,
                direction: direction,
                destination: destination,
                allowsDecomposition: allowsDecomposition
            )
        }

        if textRanges.isEmpty {
            return
        }

        textContentStorage.performEditingTransaction {
            for textRange in textRanges {
                replaceCharacters(in: textRange, with: "")
            }
        }
    }
}

#if os(macOS)
import AppKit

extension MDTextView: NSTextInputClient {
    func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
        textContentStorage.attributedString?.attributedSubstring(from: range)
    }

    func validAttributesForMarkedText() -> [NSAttributedString.Key] {
        [.font, .foregroundColor, .glyphInfo, .kern, .ligature, .link, .markedClauseSegment, .obliqueness, .paragraphStyle, .shadow, .spellingState, .strikethroughColor, .strikethroughStyle, .strokeColor, .strokeWidth, .superscript, .textAlternatives, .textEffect, .toolTip, .underlineColor, .underlineStyle, .verticalGlyphForm, .writingDirection]
    }

    func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
        guard let textRange = convertRange(from: range) else {
            return .zero
        }

        var rect: NSRect = .zero
        textLayoutManager.enumerateTextSegments(in: textRange, type: .selection, options: .rangeNotRequired) { _, textSegmentFrame, _, _ in
            rect = window!.convertToScreen(convert(textSegmentFrame, to: nil))
            return false
        }

        return rect
    }

    func characterIndex(for point: NSPoint) -> Int {
        guard let textLayoutFragment = textLayoutManager.textLayoutFragment(for: point) else {
            return NSNotFound
        }

        return textLayoutManager.offset(
            from: textLayoutManager.documentRange.location, to: textLayoutFragment.rangeInElement.location
        )
    }

    func hasMarkedText() -> Bool {
        false
    }

    func markedRange() -> NSRange {
        NSRange(location: NSNotFound, length: 0)
    }

    func selectedRange() -> NSRange {
        if let selectionTextRange = textLayoutManager.textSelections.first?.textRanges.first {
            return convertRange(from: selectionTextRange)
        }
        return NSRange(location: NSNotFound, length: 0)
    }

    func setMarkedText(_ string: Any, selectedRange: NSRange, replacementRange: NSRange) {
        print("set marked text")
    }

    func unmarkText() {

    }

    override func insertText(_ string: Any) {
        guard let string = string as? String else {
            return
        }
        for textRange in textLayoutManager.textSelections.flatMap(\.textRanges) {
            replaceCharacters(in: textRange, with: string)
        }
    }

    func insertText(_ string: Any, replacementRange: NSRange) {
        guard let string = string as? String else {
            return
        }
        textContentStorage?.performEditingTransaction {
            if let textRange = convertRange(from: replacementRange) {
                replaceCharacters(in: textRange, with: string)
            } else {
                insertText(string)
            }
        }
    }

}
#else
import UIKit

extension MDTextView: UIKeyInput {
    override var canBecomeFirstResponder: Bool {
        true
    }
    var hasText: Bool {
        textContentStorage.textStorage!.string.count > 0
    }

    func insertText(_ text: String) {
        for textRange in textLayoutManager!.textSelections.flatMap(\.textRanges) {
            replaceCharacters(in: textRange, with: text)
        }
        scrollToCaret()
    }

    func deleteBackward() {
        delete(direction: .backward, destination: .character, allowsDecomposition: false)
    }

}
#endif
