//
//  NSFont+.swift
//  
//
//  Created by seeu on 2022/9/9.
//

import AppKit

extension NSFont {
    func withTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
        let fd = fontDescriptor.withSymbolicTraits(traits)
        return NSFont(descriptor: fd, size: pointSize)!
    }

    func italics() -> NSFont {
        return withTraits(.italic)
    }
}
