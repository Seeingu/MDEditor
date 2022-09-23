//
//  MDStyleMeta.swift
//  
//
//  Created by seeu on 2022/9/12.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import MDCommon

public struct SupportParagraphStyle {
    public var lineHeight: Float
    public var backgroundColor: MDColor?
}

public struct MDSupportStyle {
    public var font: MDFont
    public var paragraph: SupportParagraphStyle
    public var foregroundColor: MDColor?
    public var backgroundColor: MDColor?
    public var isLink: Bool?
    init() {
        self.font = MDFont.mdDefault
        self.paragraph = SupportParagraphStyle(lineHeight: 1.5)
    }

    func withFontSize(_ size: CGFloat) -> Self {
        var style = self
        style.font = style.font.withSize(size)
        return style
    }
    func withItalics() -> Self {
        var style = self
        style.font = style.font.withItalics()
        return style
    }
    func withBold() -> Self {
        var style = self
        style.font = style.font.withBold()
        return style
    }
}

// MARK: - Block

public struct MDHeadingStyles {
    public var level: MDSupportStyle
    public var plainText: MDSupportStyle

    init(level: MDSupportStyle, plainText: MDSupportStyle) {
        self.level = level
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        self.level = style
        self.plainText = style
    }
}

public struct MDCodeBlockStyles {
    public var language: MDSupportStyle
    public var quote: MDSupportStyle
    public var plainText: MDSupportStyle

    init(language: MDSupportStyle, quote: MDSupportStyle, plainText: MDSupportStyle) {
        self.language = language
        self.quote = quote
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        self.language = style
        self.quote = style
        self.plainText = style
    }
}

public struct MDLineBreakStyles {
    public var plainText: MDSupportStyle

    init(plainText: MDSupportStyle) {
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        self.plainText = style
    }
}

public struct MDBlockQuoteStyles {
    public var symbol: MDSupportStyle
    public var plainText: MDSupportStyle

    init(symbol: MDSupportStyle, plainText: MDSupportStyle) {
        self.symbol = symbol
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        self.symbol = style
        self.plainText = style
    }
}

public struct MDUnorderedListStyles {
    public var prefix: MDSupportStyle
    public var checkbox: MDSupportStyle?
    /// only set style on plain text, not inline style
    public var plainText: MDSupportStyle
    init(prefix: MDSupportStyle, checkbox: MDSupportStyle? = nil, plainText: MDSupportStyle) {
        self.prefix = prefix
        self.checkbox = checkbox
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        self.prefix = style
        self.checkbox = style
        self.plainText = style
    }
}

public struct MDOrderedListStyles {
    public var index: MDSupportStyle
    /// only set style on plain text, not inline style
    public var plainText: MDSupportStyle
    init(index: MDSupportStyle, plainText: MDSupportStyle) {
        self.index = index
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        index = style
        plainText = style
    }
}

public struct MDTableStyles {
    public var head: MDSupportStyle
    public var item: MDSupportStyle
    public var verticalDivider: MDSupportStyle
    public var horizontalDivider: MDSupportStyle

    init(
        head: MDSupportStyle,
        item: MDSupportStyle,
        verticalDivider: MDSupportStyle,
        horizontalDivider: MDSupportStyle
    ) {
        self.head = head
        self.item = item
        self.verticalDivider = verticalDivider
        self.horizontalDivider = horizontalDivider
    }

    init(default style: MDSupportStyle) {
        head = style
        item = style
        verticalDivider = style
        horizontalDivider = style
    }
}

// MARK: - Inline
public struct MDInlineCodeStyles {
    public var quote: MDSupportStyle
    public var code: MDSupportStyle

    init(quote: MDSupportStyle, code: MDSupportStyle) {
        self.quote = quote
        self.code = code
    }

    init(default style: MDSupportStyle) {
        quote = style
        code = style
    }
}

public struct MDLinkStyles {
    public var text: MDSupportStyle
    public var link: MDSupportStyle
    init(text: MDSupportStyle, link: MDSupportStyle) {
        self.text = text
        self.link = link
    }
    init(default style: MDSupportStyle) {
        text = style
        link = style
    }

}

public struct MDImageStyles {
    public var title: MDSupportStyle
    public var link: MDSupportStyle
    public var description: MDSupportStyle?
    init(title: MDSupportStyle, link: MDSupportStyle, description: MDSupportStyle? = nil) {
        self.title = title
        self.link = link
        self.description = description
    }

    init(default style: MDSupportStyle) {
        title = style
        link = style
        description = style
    }
}

public struct MDStrikeThroughStyles {
    public var symbol: MDSupportStyle
    public var plainText: MDSupportStyle

    init(symbol: MDSupportStyle, plainText: MDSupportStyle) {
        self.symbol = symbol
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        symbol = style
        plainText = style
    }
}

public struct MDEmphasisStyles {
    public var symbol: MDSupportStyle
    public var plainText: MDSupportStyle

    init(symbol: MDSupportStyle, plainText: MDSupportStyle) {
        self.symbol = symbol
        self.plainText = plainText
    }

    init(default style: MDSupportStyle) {
        symbol = style
        plainText = style
    }

}
