//
//  ThemeProtocol.swift
//  
//
//  Created by seeu on 2022/9/12.
//

import Foundation
import MDCommon

/// editor setting
public protocol EditorThemeDelegate: AnyObject {
    func loadEditorStyles(_ defaultStyles: EditorStyles) -> EditorStyles
}

/// markdown content setting
public protocol MarkdownThemeDelegate: AnyObject {
    func loadDefaultStyles() -> MDSupportStyle
    func loadHeadingStyles(_ defaultStyle: MDSupportStyle, level: Int) -> MDHeadingStyles
    func loadCodeBlockStyles(_ defaultStyle: MDSupportStyle) -> MDCodeBlockStyles
    func loadInlineCodeStyles(_ defaultStyle: MDSupportStyle) -> MDInlineCodeStyles
    func loadLineBreakStyles(_ defaultStyle: MDSupportStyle) -> MDLineBreakStyles
    func emphasisStyle(emphasisType: EmphasisType) -> MDEmphasisStyles
    func loadBlockQuoteStyles(_ defaultStyle: MDSupportStyle) -> MDBlockQuoteStyles
    func loadEmphasisStyles(_ defaultStyle: MDSupportStyle, emphasisType: EmphasisType) -> MDEmphasisStyles
    func loadUnorderedListStyles(_ defaultStyle: MDSupportStyle) -> MDUnorderedListStyles
    func loadOrderedListStyles(_ defaultStyle: MDSupportStyle) -> MDOrderedListStyles
    func loadLinkStyles(_ defaultStyle: MDSupportStyle) -> MDLinkStyles
    func loadImageStyles(_ defaultStyle: MDSupportStyle) -> MDImageStyles
    func loadStrikeThroughStyles(_ defaultStyle: MDSupportStyle) -> MDStrikeThroughStyles
}
