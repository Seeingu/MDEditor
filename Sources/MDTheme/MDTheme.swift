//
//  MDTheme.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import AppKit
import MDCommon

open class ThemeProvider {
    public static let `default` = ThemeProvider()

    public weak var editorThemeDelegate: EditorThemeDelegate?
    public weak var markdownThemeDelegate: MarkdownThemeDelegate?

    public var editorStyles: EditorStyles

    public var defaultMarkdownStyles: MDSupportStyle

    public init() {
        self.editorStyles = EditorStyles.default

        self.defaultMarkdownStyles = ThemeBuilder.defaultStyle
    }

    public func headingStyle(level: Int) -> MDSupportStyle {
        if let headingStyles = markdownThemeDelegate?.loadHeadingStyles(defaultMarkdownStyles, level: level) {
            return headingStyles
        }
        return defaultMarkdownStyles
    }

    public func blockQuoteStyle() -> MDSupportStyle {
        if let blockQuoteStyles = markdownThemeDelegate?.loadBlockQuoteStyles(defaultMarkdownStyles) {
            return blockQuoteStyles
        } else {
            return defaultMarkdownStyles
        }
    }

    public func codeBlockStyle() -> MDSupportStyle {
        if let codeBlockStyles = markdownThemeDelegate?.loadCodeBlockStyles(defaultMarkdownStyles) {
            return codeBlockStyles
        } else {
            return defaultMarkdownStyles
        }
    }

    public func inlineCodeStyle() -> MDSupportStyle {
        if let inlineStyles = markdownThemeDelegate?.loadInlineCodeStyles(defaultMarkdownStyles) {
            return inlineStyles
        } else {
            return defaultMarkdownStyles
        }
    }

    public func reloadEditorStyles() {
        if let editorTheme = editorThemeDelegate {
            self.editorStyles = editorTheme.loadEditorStyles(self.editorStyles)
        }
        if let markdownTheme = markdownThemeDelegate {
            self.defaultMarkdownStyles = markdownTheme.loadDefaultStyles()
        }
    }

}
