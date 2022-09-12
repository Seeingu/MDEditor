//
//  MDMeta.swift
//  
//
//  Created by seeu on 2022/9/12.
//

import AppKit

// MARK: High level markdown style
public struct SupportParagraphStyle {
    public var lineHeight: Float
    public var backgroundColor: NSColor?
}

public struct MDSupportStyle {
    public var font: NSFont
    public var paragraph: SupportParagraphStyle
    public var foregroundColor: NSColor?
    public var backgroundColor: NSColor?
    init() {
        self.font = NSFont.monospacedSystemFont(ofSize: 20, weight: .regular)
        self.paragraph = SupportParagraphStyle(lineHeight: 1.1)
    }
}

// MARK: - L2 meta
// TODO: markdown meta info description, describe markdown layout at ast level

protocol MDBlock {
}

protocol MDBlockWithChildren: MDBlock {
    var inlineItems: [MDInline] { get set }
}

protocol MDInline {
}

struct MDCodeBlock: MDBlock {
    var language: (String, NSRange)
    var startSymbol: (String, NSRange)
    var endSymbol: (String, NSRange)
    var plainText: (String, NSRange)
}

struct MDInlineCode: MDInline {
    var startSymbol: (String, NSRange)
    var endSymbol: (String, NSRange)
    var plainText: (String, NSRange)
}

struct MDUnorderedItem: MDBlockWithChildren {
    var inlineItems: [MDInline]
    let indexInParent: Int
        // user defined input index, may not equals `indexInParent`
    let rawIndex: Int
    let checkbox: Bool
    let checked: Bool
    let plain: (String, NSRange)

}
struct MDUnorderedList: MDBlock {
    var items: [MDUnorderedItem]
}
