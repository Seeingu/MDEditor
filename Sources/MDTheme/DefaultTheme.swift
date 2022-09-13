//
//  DefaultTheme.swift
//  
//
//  Created by seeu on 2022/9/12.
//

import MDCommon
import CoreGraphics

// MARK: - Editor
public extension EditorThemeDelegate {
    func loadEditorStyles(_ defaultStyles: EditorStyles) -> EditorStyles {
        defaultStyles
    }
}

public struct EditorStyles {
    public var selectionColor: MDColor
    public var caretColor: MDColor
    public var editorBackground: MDColor
    public var padding: Float

    static let `default` = EditorStyles(selectionColor: MDColor.selectedTextBackgroundColor.withAlphaComponent(0.5), caretColor: .black, editorBackground: .white, padding: 5.0)
}

// MARK: - Markdown
// TODO: light/dark theme
public extension MarkdownThemeDelegate {
    func loadDefaultStyles() -> MDSupportStyle {
        ThemeBuilder.defaultStyle
    }

    func loadHeadingStyles(_ defaultStyle: MDSupportStyle, level: Int) -> MDSupportStyle {
        var fontSize = 18
        switch level {
            case 1:
                fontSize = 24
            case 2:
                fontSize = 22
            default:
                break
        }

        return ThemeBuilder(from: defaultStyle)
            .paragraph(lineHeight: 1.5)
            .font(MDFont.monospacedSystemFont(ofSize: CGFloat(fontSize), weight: .bold))
            .foregroundColor(.lightGray)
            .build()
    }

    func loadCodeBlockStyles(_ defaultStyle: MDSupportStyle) -> MDSupportStyle {
        ThemeBuilder(from: defaultStyle)
            .font(MDFont.systemFont(ofSize: 22))
            .foregroundColor(.systemMint)
            .build()
    }

    func loadInlineCodeStyles(_ defaultStyle: MDSupportStyle) -> MDSupportStyle {
        ThemeBuilder(from: defaultStyle)
            .font(MDFont.systemFont(ofSize: 22))
            .foregroundColor(.systemMint)
            .build()
    }

    func loadBlockQuoteStyles(_ defaultStyle: MDSupportStyle) -> MDSupportStyle {
        ThemeBuilder(from: defaultStyle)
            .foregroundColor(.white)
            .backgroundColor(.systemIndigo)
            .build()
    }

}
