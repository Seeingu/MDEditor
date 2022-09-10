//
//  NSTextLocation+.swift
//  
//
//  Created by seeu on 2022/9/8.
//

import AppKit

extension NSTextLocation {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) == .orderedSame
    }

    static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) == .orderedAscending
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs == rhs || lhs < rhs
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        return !(lhs <= rhs)
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        return !(lhs < rhs)
    }

}
