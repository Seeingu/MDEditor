//
//  ThemeProtocol.swift
//  
//
//  Created by seeu on 2022/9/12.
//

import AppKit

/// editor setting
public protocol EditorThemeDelegate: AnyObject {
    func loadEditorStyles(_ defaultStyles: EditorStyles) -> EditorStyles
}

/// markdown content setting
public protocol MarkdownThemeDelegate: AnyObject {
    func loadDefaultStyles() -> MDSupportStyle
    func loadHeadingStyles(_ defaultStyle: MDSupportStyle, level: Int) -> MDSupportStyle
    func loadCodeBlockStyles(_ defaultStyle: MDSupportStyle) -> MDSupportStyle
    func loadInlineCodeStyles(_ defaultStyle: MDSupportStyle) -> MDSupportStyle
    func loadBlockQuoteStyles(_ defaultStyle: MDSupportStyle) -> MDSupportStyle
}
