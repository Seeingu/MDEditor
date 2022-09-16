//
//  RangeIterator.swift
//  
//
//  Created by seeu on 2022/9/14.
//

import Foundation
import MDCommon

internal class MDRangeIterator {
    internal var previousRange: NSRange = NSRange(location: 0, length: 0)
    init(start: Int = 0) {
        self.previousRange = NSRange(location: start, length: 0)
    }

    @discardableResult func next( _ len: Int) -> NSRange {
        self.previousRange = NSRange(location: previousRange.upperBound, length: len)
        return self.previousRange
    }

    @discardableResult func next(_ text: String) -> MDStringLineRange {
        return (text, self.next(text.count))
    }
}
