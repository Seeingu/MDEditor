//
//  Markdown.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import Foundation

// MARK: - meta

public protocol MDBlock {
    // starts with 0
    var startLine: Int { get set }
}

public protocol MDBlockWithChildren: MDBlock {
    var inlineItems: [MDInline] { get set }
}

public protocol MDInline {
    // starts with 0
    var startLine: Int { get set }
}

    /// identify the nsrange used is relative to line info
public typealias NSRangeOfLine = NSRange

public typealias MDIntLineRange = (Int, range: NSRangeOfLine)
public typealias MDStringLineRange = (String, range: NSRangeOfLine)

public struct MDHeading: MDBlock {
    public var startLine: Int

    public var level: MDIntLineRange
    public var plainText: MDStringLineRange
    public init(startLine: Int, level: MDIntLineRange, plainText: MDStringLineRange) {
        self.startLine = startLine
        self.level = level
        self.plainText = plainText
    }
}

public typealias MDBlockQuoteBlock = (symbol: MDStringLineRange, plainText: MDStringLineRange)
public struct MDBlockQuote: MDBlock {
    public var startLine: Int
    public var endLine: Int

    public var blocks: [MDBlockQuoteBlock]
    public init(startLine: Int, endLine: Int, blocks: [MDBlockQuoteBlock]) {
        self.startLine = startLine
        self.endLine = endLine
        self.blocks = blocks
    }
}

public struct MDCodeBlock: MDBlock {
    public var startLine: Int
    public var startSymbol: MDStringLineRange
    public var language: MDStringLineRange?
    public var plainText: MDStringLineRange
    public var endSymbol: MDStringLineRange
    public init(
        startLine: Int,
        startSymbol: MDStringLineRange,
        language: MDStringLineRange?,
        plainText: MDStringLineRange,
        endSymbol: MDStringLineRange
    ) {
        self.startLine = startLine
        self.startSymbol = startSymbol
        self.language = language
        self.plainText = plainText
        self.endSymbol = endSymbol
    }
}

public struct MDLineBreak: MDBlock {
    public var startLine: Int
    public var plainText: MDStringLineRange

    public init(startLine: Int, plainText: MDStringLineRange) {
        self.startLine = startLine
        self.plainText = plainText
    }
}

public struct MDCheckbox {
    public var checked: Bool
    public init(checked: Bool) {
        self.checked = checked
    }
}
public struct MDUnorderedItem: MDBlock {
    public var startLine: Int
    public let indexInParent: Int
    public let prefix: MDStringLineRange
    public let checkbox: (MDCheckbox, NSRangeOfLine)?
    public init(
        startLine: Int,
        prefix: MDStringLineRange,
        indexInParent: Int,
        checkbox: (MDCheckbox, NSRangeOfLine)?
    ) {
        self.startLine = startLine
        self.prefix = prefix
        self.indexInParent = indexInParent
        self.checkbox = checkbox
    }
}

public struct MDUnorderedList: MDBlock {
    public var startLine: Int
    public var items: [MDUnorderedItem]
    public init(startLine: Int, items: [MDUnorderedItem]) {
        self.startLine = startLine
        self.items = items
    }
}

public struct MDOrderedList: MDBlockWithChildren {
    public var startLine: Int
    public var inlineItems: [MDInline]
    public init(startLine: Int, inlineItems: [MDInline]) {
        self.startLine = startLine
        self.inlineItems = inlineItems
    }

}

// MARK: - inline

public struct MDInlineCode: MDInline {
    public var startLine: Int
    public var startSymbol: MDStringLineRange
    public var plainText: MDStringLineRange
    public var endSymbol: MDStringLineRange
    public init(
        startLine: Int,
        startSymbol: MDStringLineRange,
        plainText: MDStringLineRange,
        endSymbol: MDStringLineRange
    ) {
        self.startLine = startLine
        self.startSymbol = startSymbol
        self.plainText = plainText
        self.endSymbol = endSymbol
    }
}

public enum EmphasisType {
    case strong
    case italic
    case strongAndItalic
}

public struct MDEmphasis: MDInline {
    public var startLine: Int

    public var startSymbol: MDStringLineRange
    public var endSymbol: MDStringLineRange
    public var plainText: MDStringLineRange
    public var type: EmphasisType

    public init(startLine: Int, startSymbol: MDStringLineRange, plainText: MDStringLineRange, endSymbol: MDStringLineRange, type: EmphasisType) {
        self.startLine = startLine
        self.startSymbol = startSymbol
        self.endSymbol = endSymbol
        self.plainText = plainText
        self.type = type
    }

}

public struct MDText: MDInline {
    public var startLine: Int

    public var text: MDStringLineRange

    public init(startLine: Int, text: MDStringLineRange) {
        self.startLine = startLine
        self.text = text
    }
}

public struct MDLink: MDInline {
    public var startLine: Int
    public var titleLeftSymbol: MDStringLineRange
    public var title: MDStringLineRange
    public var titleRightSymbol: MDStringLineRange
    public var linkLeftSymbol: MDStringLineRange
    public var link: MDStringLineRange
    public var linkRightSymbol: MDStringLineRange
    public init(
        startLine: Int,
        titleLeftSymbol: MDStringLineRange,
        title: MDStringLineRange,
        titleRightSymbol: MDStringLineRange,
        linkLeftSymbol: MDStringLineRange,
        link: MDStringLineRange,
        linkRightSymbol: MDStringLineRange
    ) {
        self.startLine = startLine
        self.titleLeftSymbol = titleLeftSymbol
        self.title = title
        self.titleRightSymbol = titleRightSymbol
        self.linkLeftSymbol = linkLeftSymbol
        self.link = link
        self.linkRightSymbol = linkRightSymbol
    }

}

public struct MDImage: MDInline {
    public var startLine: Int
    public var prefixSymbol: MDStringLineRange
    public var titleLeftSymbol: MDStringLineRange
    public var title: MDStringLineRange
    public var titleRightSymbol: MDStringLineRange
    public var linkLeftSymbol: MDStringLineRange
    public var link: MDStringLineRange
    public var linkRightSymbol: MDStringLineRange
    public init(
        startLine: Int,
        prefixSymbol: MDStringLineRange,
        titleLeftSymbol: MDStringLineRange,
        title: MDStringLineRange,
        titleRightSymbol: MDStringLineRange,
        linkLeftSymbol: MDStringLineRange,
        link: MDStringLineRange,
        linkRightSymbol: MDStringLineRange
    ) {
        self.startLine = startLine
        self.prefixSymbol = prefixSymbol
        self.titleLeftSymbol = titleLeftSymbol
        self.title = title
        self.titleRightSymbol = titleRightSymbol
        self.linkLeftSymbol = linkLeftSymbol
        self.link = link
        self.linkRightSymbol = linkRightSymbol
    }

}

public struct MDStrikeThrough: MDInline {
    public var startLine: Int

    public var startSymbol: MDStringLineRange
    public var endSymbol: MDStringLineRange
    public var plainText: MDStringLineRange

    public init(
        startLine: Int,
        startSymbol: MDStringLineRange,
        plainText: MDStringLineRange,
        endSymbol: MDStringLineRange
    ) {
        self.startLine = startLine
        self.startSymbol = startSymbol
        self.endSymbol = endSymbol
        self.plainText = plainText
    }

}

/// Markdown type enumeration
public enum MDType {
    case paragraph
    case heading(MDHeading)
    case codeBlock(MDCodeBlock)
    case codeInline(MDInlineCode)
    case blockQuote(MDBlockQuote)
    case lineBreak(MDLineBreak)
    case emphasis(MDEmphasis)
    case text(MDText)
    case image(MDImage)
    case link(MDLink)
    case strikeThrough(MDStrikeThrough)
    case orderedList(MDOrderedList)
    case unorderedList(MDUnorderedList)
}
