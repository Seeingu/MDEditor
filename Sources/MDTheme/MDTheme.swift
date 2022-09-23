//
//  MDTheme.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import MDCommon

public struct EditorStyles {
    public var selectionColor: MDColor
    public var caretColor: MDColor
    public var editorBackground: MDColor
    public var padding: Float
}

open class ThemeProvider {
    public static let `default` = ThemeProvider()

    public var editorThemeDelegate: EditorThemeDelegate = DefaultEditorTheme()
    public var markdownThemeDelegate: MarkdownThemeDelegate = DefaultMarkdownTheme()

    public var editorStyles: EditorStyles {
        editorThemeDelegate.loadEditorStyles(colorScheme: colorScheme)
    }

    public var colorScheme: MDColorScheme

    public var defaultMarkdownStyles: MDSupportStyle {
        markdownThemeDelegate.loadDefaultStyles(colorScheme: colorScheme)
    }

    public init(_ colorScheme: MDColorScheme = .light) {
        self.colorScheme = colorScheme
    }

    public func headingStyle(level: Int) -> MDHeadingStyles {
         markdownThemeDelegate.loadHeadingStyles(defaultMarkdownStyles, level: level)
    }

    public func blockQuoteStyle() -> MDBlockQuoteStyles {
        markdownThemeDelegate.loadBlockQuoteStyles(defaultMarkdownStyles)
    }

    public func unorderedListStyle() -> MDUnorderedListStyles {
        markdownThemeDelegate.loadUnorderedListStyles(defaultMarkdownStyles)
    }

    public func orderedListStyle() -> MDOrderedListStyles {
        markdownThemeDelegate.loadOrderedListStyles(defaultMarkdownStyles)
    }

    public func tableStyle() -> MDTableStyles {
        markdownThemeDelegate.loadTableStyles(defaultMarkdownStyles)
    }

    public func lineBreakStyle() -> MDLineBreakStyles {
        markdownThemeDelegate.loadLineBreakStyles(defaultMarkdownStyles)
    }

    public func codeBlockStyle() -> MDCodeBlockStyles {
        markdownThemeDelegate.loadCodeBlockStyles(defaultMarkdownStyles)
    }

    public func inlineCodeStyle() -> MDInlineCodeStyles {
        markdownThemeDelegate.loadInlineCodeStyles(defaultMarkdownStyles)
    }

    public func emphasisStyle(emphasisType: EmphasisType) -> MDEmphasisStyles {
        markdownThemeDelegate.loadEmphasisStyles(defaultMarkdownStyles, emphasisType: emphasisType)
    }

    public func linkStyle() -> MDLinkStyles {
        markdownThemeDelegate.loadLinkStyles(defaultMarkdownStyles)
    }

    public func imageStyle() -> MDImageStyles {
        markdownThemeDelegate.loadImageStyles(defaultMarkdownStyles)
    }

    public func strikeThroughStyle() -> MDStrikeThroughStyles {
        markdownThemeDelegate.loadStrikeThroughStyles(defaultMarkdownStyles)
    }

}
