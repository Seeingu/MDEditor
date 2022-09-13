//
//  NSTextLayoutManager+.swift
//  
//
//  Created by seeu on 2022/9/8.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension NSTextLayoutManager {
    public var insertionPointLocation: NSTextLocation? {
        guard let textSelection = textSelections.first(where: { !$0.isLogical }) else {
            return nil
        }
        return textSelectionNavigation.resolvedInsertionLocation(for: textSelection, writingDirection: .leftToRight)
    }

    private func substring(for range: NSTextRange) -> String? {
        guard !range.isEmpty else { return nil }
        var output = String()
        enumerateSubstrings(from: range.location, options: .byComposedCharacterSequences, using: { (substring, textRange, _, stop) in
            if let substring = substring {
                output += substring
            }

            if textRange.endLocation >= range.endLocation {
                stop.pointee = true
            }
        })
        return output
    }

    func textSelectionsString() -> String? {
        return textSelections.flatMap(\.textRanges).reduce(nil) { partialResult, textRange in
            guard let substring = substring(for: textRange) else {
                return partialResult
            }

            var partialResult = partialResult
            if partialResult == nil {
                partialResult = ""
            }

            return partialResult?.appending(substring)
        }
    }

        ///  A text segment is both logically and visually contiguous portion of the text content inside a line fragment.
    public func textSelectionSegmentFrame(at location: NSTextLocation, type: NSTextLayoutManager.SegmentType) -> CGRect? {
        textSelectionSegmentFrame(in: NSTextRange(location: location), type: type)
    }

    public func textSelectionSegmentFrame(in textRange: NSTextRange, type: NSTextLayoutManager.SegmentType) -> CGRect? {
        var result: CGRect?
        enumerateTextSegments(in: textRange, type: type, options: [.rangeNotRequired, .upstreamAffinity]) { _, textSegmentFrame, _, _ -> Bool in
            result = textSegmentFrame
            return false
        }
        return result
    }

    public var firstSelection: NSTextSelection? {
        self.textSelections.first
    }

}
