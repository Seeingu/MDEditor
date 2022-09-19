//
//  MDTextView+Rect.swift
//  
//
//  Created by seeu on 2022/9/18.
//

import Foundation

#if os(macOS)
extension MDTextView {
    internal func findRects(forCharacterRange range: NSRange) -> [NSRect] {
        guard let textRange = convertRange(from: range) else {
            return []
        }

        var rects: [NSRect] = []
        textLayoutManager.enumerateTextSegments(in: textRange, type: .selection, options: .rangeNotRequired) { _, textSegmentFrame, _, _ in
            rects.append(window!.convertToScreen(convert(textSegmentFrame, to: nil)))
            return true
        }

        return rects
    }

}
#endif
