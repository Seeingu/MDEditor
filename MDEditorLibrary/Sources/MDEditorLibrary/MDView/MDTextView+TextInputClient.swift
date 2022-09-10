//
//  MDTextView+NSTextInputClient.swift
//  
//
//  Created by seeu on 2022/9/7.
//

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
            print("Warning: insert text of unknown type \(type(of: string))")
            return
        }
        for textRange in textLayoutManager.textSelections.flatMap(\.textRanges) {
            replaceCharacters(in: textRange, with: string)
        }
    }

    func insertText(_ string: Any, replacementRange: NSRange) {
        guard let string = string as? String else {
            print("Warning: insert text of unknown type \(type(of: string))")
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
