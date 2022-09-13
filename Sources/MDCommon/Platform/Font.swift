//
//  Font.swift
//  
//
//  Created by seeu on 2022/9/12.
//

import Foundation

#if os(macOS)
import AppKit

public typealias MDFont = NSFont
public typealias MDFontDescriptor = NSFontDescriptor

extension MDFont {
    public func withTraits(_ traits: MDFontDescriptor.SymbolicTraits) -> MDFont {
        let fd = fontDescriptor.withSymbolicTraits(traits)
        return MDFont(descriptor: fd, size: pointSize)!
    }

    public func italics() -> MDFont {
        return withTraits(.italic)
    }
}

#else
import UIKit

public typealias MDFont = UIFont
public typealias MDFontDescriptor = UIFontDescriptor

extension MDFont {
    public func withTraits(_ traits: MDFontDescriptor.SymbolicTraits) -> MDFont {
        let fd = fontDescriptor.withSymbolicTraits(traits)
        return MDFont(descriptor: fd!, size: pointSize)
    }

    public func italics() -> MDFont {
        return withTraits(.traitItalic)
    }
}

#endif
