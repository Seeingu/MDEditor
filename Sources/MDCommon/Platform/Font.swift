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
    func withTraits(_ traits: MDFontDescriptor.SymbolicTraits) -> MDFont {
        let fd = fontDescriptor.withSymbolicTraits(traits)
        return MDFont(descriptor: fd, size: pointSize)!
    }

    public func withItalics() -> MDFont {
        if fontDescriptor.symbolicTraits.contains(.bold) {
            return withTraits([.italic, .bold])
        }
        return withTraits(.italic)
    }

    public func withBold() -> MDFont {
        return withTraits(.bold)
    }

}

#else
import UIKit

public typealias MDFont = UIFont
public typealias MDFontDescriptor = UIFontDescriptor

extension MDFont {

    func withTraits(_ traits: MDFontDescriptor.SymbolicTraits) -> MDFont {
        let fd = fontDescriptor.withSymbolicTraits(traits)
        return MDFont(descriptor: fd!, size: pointSize)
    }

    public func withItalics() -> MDFont {
        if fontDescriptor.symbolicTraits.contains(.traitBold) {
            return withTraits([.traitBold, .traitItalic])
        }
        return withTraits(.traitItalic)
    }

    public func withBold() -> MDFont {
        return withTraits(.traitBold)
    }
}

#endif

// MARK: - common
extension MDFont {
    public static var `mdDefault` = MDFont.systemFont(ofSize: 16, weight: .regular)
    public static var `mdDefaultMono` = MDFont.monospacedSystemFont(ofSize: 16, weight: .regular)
}
