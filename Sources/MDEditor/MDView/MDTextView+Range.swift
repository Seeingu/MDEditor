//
//  MDTextView+Range.swift
//  
//
//  Created by seeu on 2022/9/10.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension MDTextView {
    internal func convertRange(from nsRange: NSRange) -> NSTextRange? {
        guard let start = textContentStorage.location(textContentStorage.documentRange.location, offsetBy: nsRange.location) else {
            return nil
        }
        let end = textContentStorage.location(start, offsetBy: nsRange.length)
        return NSTextRange(location: start, end: end)
    }

    internal func convertRange(from textRange: NSTextRange) -> NSRange {
        let offset = textContentStorage.offset(from: textContentStorage.documentRange.location, to: textRange.location)
        let length = textContentStorage.offset(from: textRange.location, to: textRange.endLocation)
        return NSRange(location: offset, length: length)
    }
}
