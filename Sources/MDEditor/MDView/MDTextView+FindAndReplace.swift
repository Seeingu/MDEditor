//
//  MDTextView+FindAndReplace.swift
//  
//
//  Created by seeu on 2022/9/18.
//

#if os(macOS)
import AppKit

extension MDTextView: NSTextFinderClient {
    internal func showFinderBar() {
        textFinder.performAction(.showFindInterface)
    }

    var string: String {
        get {
            self.mdString
        }
    }

    func stringLength() -> Int {
        self.mdString.count
    }

    var isSelectable: Bool { true }

    var firstSelectedRange: NSRange {
        get {
            guard let textRange = textLayoutManager.firstSelection?.firstTextRange else {
                return NSRange(location: NSNotFound, length: 0)
            }
            return convertRange(from: textRange)
        }
    }

    var selectedRanges: [NSValue] {
        get {
            let selections = textLayoutManager.textSelections
            return selections
                .flatMap(\.textRanges)
                .compactMap(convertRange(from:))
                .map { NSValue(range: $0) }
        }
        set {
            let textRanges = newValue.map(\.rangeValue).compactMap(convertRange(from:))

            textLayoutManager.textSelections = [NSTextSelection(textRanges, affinity: .downstream, granularity: .character)]
            updateSelectionHighlights()
            scrollToSelection()
        }
    }

    func contentView(at index: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView {
        // Only has single text view for now, return self directly
        return self
    }

    func rects(forCharacterRange range: NSRange) -> [NSValue]? {
        return findRects(forCharacterRange: range).map { NSValue(rect: $0) }
    }

    // TODO: support system highlight

    // MARK: - Replace

    func shouldReplaceCharacters(inRanges ranges: [NSValue], with strings: [String]) -> Bool {
        true
    }

    func replaceCharacters(in range: NSRange, with string: String) {
        guard range.length != 0, let textRange = convertRange(from: range) else { return }
        replaceCharacters(in: textRange, with: string)
    }

}

#endif
