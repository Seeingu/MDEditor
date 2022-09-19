//
//  NSTextSelection+.swift
//  
//
//  Created by seeu on 2022/9/18.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension NSTextSelection {
    public var firstTextRange: NSTextRange? {
        self.textRanges.first
    }
}
