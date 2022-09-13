//
//  NSTextLocation+.swift
//  
//
//  Created by seeu on 2022/9/8.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

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
