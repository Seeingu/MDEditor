//
//  MDTheme.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import MDCommon

open class ThemeProvider {
    public static let `default` = ThemeProvider()

    public weak var editorThemeDelegate: EditorThemeDelegate?
    public weak var markdownThemeDelegate: MarkdownThemeDelegate?

    public var editorStyles: EditorStyles

    public var defaultMarkdownStyles: MDSupportStyle

    public var colorScheme: MDColorScheme

    public init(_ colorScheme: MDColorScheme = .light) {
        self.colorScheme = colorScheme
        if colorScheme == .dark {
            self.editorStyles = EditorStyles.darkDefault
            self.defaultMarkdownStyles = ThemeBuilder.defaultDarkStyle

        } else {
            self.editorStyles = EditorStyles.default
            self.defaultMarkdownStyles = ThemeBuilder.defaultStyle
        }
    }

    public func headingStyle(level: Int) -> MDHeadingStyles {
        if let headingStyles = markdownThemeDelegate?.loadHeadingStyles(defaultMarkdownStyles, level: level) {
            return headingStyles
        }
        return MDHeadingStyles(default: defaultMarkdownStyles)
    }

    public func blockQuoteStyle() -> MDBlockQuoteStyles {
        if let blockQuoteStyles = markdownThemeDelegate?.loadBlockQuoteStyles(defaultMarkdownStyles) {
            return blockQuoteStyles
        } else {
            return MDBlockQuoteStyles(default: defaultMarkdownStyles)
        }
    }

    public func unorderedListStyle() -> MDUnorderedListStyles {
        if let unorderedListStyles = markdownThemeDelegate?.loadUnorderedListStyles(defaultMarkdownStyles) {
            return unorderedListStyles
        }
        return MDUnorderedListStyles(default: defaultMarkdownStyles)
    }

    public func orderedListStyle() -> MDOrderedListStyles {
        if let orderedListStyles = markdownThemeDelegate?.loadOrderedListStyles(defaultMarkdownStyles) {
            return orderedListStyles
        }
        return MDOrderedListStyles(default: defaultMarkdownStyles)
    }

    public func tableStyle() -> MDTableStyles {
        if let tableStyels = markdownThemeDelegate?.loadTableStyles(defaultMarkdownStyles) {
            return tableStyels
        }
        return MDTableStyles(default: defaultMarkdownStyles)
    }

    public func lineBreakStyle() -> MDLineBreakStyles {
        if let lineBreakStyles = markdownThemeDelegate?.loadLineBreakStyles(defaultMarkdownStyles) {
            return lineBreakStyles
        }
        return MDLineBreakStyles(default: defaultMarkdownStyles)
    }

    public func codeBlockStyle() -> MDCodeBlockStyles {
        if let codeBlockStyles = markdownThemeDelegate?.loadCodeBlockStyles(defaultMarkdownStyles) {
            return codeBlockStyles
        } else {
            return MDCodeBlockStyles(default: defaultMarkdownStyles)
        }
    }

    public func inlineCodeStyle() -> MDInlineCodeStyles {
        if let inlineStyles = markdownThemeDelegate?.loadInlineCodeStyles(defaultMarkdownStyles) {
            return inlineStyles
        } else {
            return MDInlineCodeStyles(default: defaultMarkdownStyles)
        }
    }

    public func emphasisStyle(emphasisType: EmphasisType) -> MDEmphasisStyles {
        if let emphasisStyles = markdownThemeDelegate?.loadEmphasisStyles(defaultMarkdownStyles, emphasisType: emphasisType) {
            return emphasisStyles
        }
        return MDEmphasisStyles(default: defaultMarkdownStyles)

    }

    public func linkStyle() -> MDLinkStyles {
        if let linkStyles = markdownThemeDelegate?.loadLinkStyles(defaultMarkdownStyles) {
            return linkStyles
        }
        return MDLinkStyles(default: defaultMarkdownStyles)
    }

    public func imageStyle() -> MDImageStyles {
        if let imageStyles = markdownThemeDelegate?.loadImageStyles(defaultMarkdownStyles) {
            return imageStyles
        }
        return MDImageStyles(default: defaultMarkdownStyles)
    }

    public func strikeThroughStyle() -> MDStrikeThroughStyles {
        if let strikeThroughStyles = markdownThemeDelegate?.loadStrikeThroughStyles(defaultMarkdownStyles) {
            return strikeThroughStyles
        }
        return MDStrikeThroughStyles(default: defaultMarkdownStyles)
    }

    public func reloadEditorStyles() {
        if let editorTheme = editorThemeDelegate {
            self.editorStyles = editorTheme.loadEditorStyles(self.editorStyles)
        }
        if let markdownTheme = markdownThemeDelegate {
            self.defaultMarkdownStyles = markdownTheme.loadDefaultStyles(colorScheme: colorScheme)
        }
    }

}
