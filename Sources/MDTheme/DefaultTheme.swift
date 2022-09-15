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

    func loadHeadingStyles(_ defaultStyle: MDSupportStyle, level: Int) -> MDHeadingStyles {
        var fontSize: CGFloat = 18
        switch level {
            case 1:
                fontSize = 24
            case 2:
                fontSize = 22
            default:
                break
        }

        let headingStyle = ThemeBuilder(from: defaultStyle)
            .paragraph(lineHeight: 1.5)
            .font(MDFont.monospacedSystemFont(ofSize: fontSize, weight: .bold))
            .build()
        return MDHeadingStyles(level: defaultStyle.withFontSize(fontSize).withGrayText(), plainText: headingStyle)
    }

    func loadCodeBlockStyles(_ defaultStyle: MDSupportStyle) -> MDCodeBlockStyles {
        let codeStyle = ThemeBuilder(from: defaultStyle)
            .font(MDFont.mdDefault)
            .foregroundColor(.systemPink)
            .build()
        return MDCodeBlockStyles(language: defaultStyle.withItalics(), quote: defaultStyle.withGrayText(), plainText: codeStyle)
    }

    func loadInlineCodeStyles(_ defaultStyle: MDSupportStyle) -> MDInlineCodeStyles {
        let codeStyle = ThemeBuilder(from: defaultStyle)
            .font(MDFont.systemFont(ofSize: 22))
            .build()
        return MDInlineCodeStyles(quote: defaultStyle.withGrayText(), code: codeStyle)
    }

    func loadLineBreakStyles(_ defaultStyle: MDSupportStyle) -> MDLineBreakStyles {
        return MDLineBreakStyles(plainText: defaultStyle.withFontSize(18))
    }

    func loadBlockQuoteStyles(_ defaultStyle: MDSupportStyle) -> MDBlockQuoteStyles {
        let plainTextStyle = ThemeBuilder(from: defaultStyle)
            .foregroundColor(.white)
            .paragraph(backgroundColor: .systemIndigo)
            .build()
        return MDBlockQuoteStyles(symbol: defaultStyle.withGrayText(), plainText: plainTextStyle)
    }

    func loadEmphasisStyles(_ defaultStyle: MDSupportStyle, emphasisType: EmphasisType) -> MDEmphasisStyles {
        var builder = ThemeBuilder(from: defaultStyle)
        switch emphasisType {
            case .italic:
                builder = builder.font(MDFont.monospacedSystemFont(ofSize: 20, weight: .regular).italics())
            case .strong:
                builder = builder.font(MDFont.monospacedSystemFont(ofSize: 20, weight: .bold))
            case .strongAndItalic:
                builder = builder.font(MDFont.monospacedSystemFont(ofSize: 20, weight: .bold).italics())
        }
        let plainTextStyle = builder.build()
        return MDEmphasisStyles(symbol: defaultStyle.withGrayText(), plainText: plainTextStyle)
    }

    func loadUnorderedListStyles(_ defaultStyle: MDSupportStyle) -> MDUnorderedListStyles {
        let plainTextStyle = ThemeBuilder(from: defaultStyle)
            .build()
        return MDUnorderedListStyles(prefix: defaultStyle.withGrayText(), checkbox: defaultStyle.withGrayText(), plainText: plainTextStyle)
    }

    func loadOrderedListStyles(_ defaultStyle: MDSupportStyle) -> MDOrderedListStyles {
        let plainTextStyle = ThemeBuilder(from: defaultStyle)
            .font(MDFont.monospacedSystemFont(ofSize: 20, weight: .thin))
            .build()
        return MDOrderedListStyles(index: defaultStyle.withGrayText(), plainText: plainTextStyle)
    }
    func loadLinkStyles(_ defaultStyle: MDSupportStyle) -> MDLinkStyles {
        let textStyle = defaultStyle.withGrayText()
        let linkStyle = ThemeBuilder(from: defaultStyle)
            .build()
        return MDLinkStyles(text: textStyle, link: linkStyle)
    }
    func loadImageStyles(_ defaultStyle: MDSupportStyle) -> MDImageStyles {
        let titleStyle = defaultStyle.withGrayText()
        let linkStyle = ThemeBuilder(from: defaultStyle)
            .build()
        return MDImageStyles(title: titleStyle, link: linkStyle)

    }

    func loadStrikeThroughStyles(_ defaultStyle: MDSupportStyle) -> MDStrikeThroughStyles {
        return MDStrikeThroughStyles(symbol: defaultStyle.withGrayText(), plainText: defaultStyle)
    }

}
