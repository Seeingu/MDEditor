//
//  MDTextView+Input.swift
//  
//
//  Created by seeu on 2022/9/7.
//

// MARK: - Common
import MDCommon

extension MDTextView {
    internal func replaceCharacters(in range: NSTextRange, with string: String) {
        if !isEditable {
            return
        }
        defer {
            relayout()
        }

        stateModel.undoStackManager.registerUndo(
            source: mdString,
            caretLocation: caretLocation,
            editRange: range)

        textContentStorage.textStorage?.replaceCharacters(in: convertRange(from: range), with: string)
        let newString = textContentStorage.textStorage!.string
        self.setString(newString)
        textViewDelegate?.onTextChange(newString)
    }

    // MARK: - String processing
    func updateString(_ string: String, textRanges: [NSTextRange]) {
        for textRange in textRanges {
            replaceCharacters(in: textRange, with: string)
        }
    }
    func updateString(_ string: String, ranges: [NSRange]) {
        updateString(string, textRanges: ranges.compactMap { convertRange(from: $0) })
    }

    func insertString(_ string: String) {
        updateString(string, ranges: textLayoutManager.textSelections.flatMap(\.textRanges).map { convertRange(from: $0) })
    }

    func insertString(_ string: String, replacementRange: NSRange) {
        updateString(string, ranges: [replacementRange])
    }

    func deleteString(textRanges: [NSTextRange]) {
        updateString("", textRanges: textRanges)
    }

    func delete(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, allowsDecomposition: Bool) {
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
        deleteString(textRanges: textRanges)
    }
}

#if os(macOS)
import AppKit

// MARK: - mac: NSTextInputClient

extension MDTextView: NSTextInputClient {
    func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
        textContentStorage.attributedString?.attributedSubstring(from: range)
    }

    func validAttributesForMarkedText() -> [NSAttributedString.Key] {
        [.font, .foregroundColor, .glyphInfo, .kern, .ligature, .link, .markedClauseSegment, .obliqueness, .paragraphStyle, .shadow, .spellingState, .strikethroughColor, .strikethroughStyle, .strokeColor, .strokeWidth, .superscript, .textAlternatives, .textEffect, .toolTip, .underlineColor, .underlineStyle, .verticalGlyphForm, .writingDirection]
    }

    func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
        return findRects(forCharacterRange: range).first ?? .zero
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
        insertString(string)
    }

    func insertText(_ string: Any, replacementRange: NSRange) {
        guard let string = string as? String else {
            return
        }
        // check textRange validation first
        if let _ = convertRange(from: replacementRange) {
            insertString(string, replacementRange: replacementRange)
        } else {
            insertString(string)
        }

    }

}
#else
import UIKit

// MARK: iOS: UIKeyInput
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
