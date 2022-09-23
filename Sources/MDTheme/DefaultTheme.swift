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
    func loadEditorStyles(colorScheme: MDColorScheme) -> EditorStyles {
        if colorScheme == .dark {
            return EditorStyles(
                selectionColor: MDColor.selectedTextBackgroundColor.withAlphaComponent(0.5),
                caretColor: .white,
                editorBackground: MDColor(red: 7 / 255, green: 54 / 255, blue: 66 / 255, alpha: 1),
                padding: 5.0)
        } else {
            return EditorStyles(
                selectionColor: MDColor.selectedTextBackgroundColor.withAlphaComponent(0.5),
                caretColor: .black,
                editorBackground: MDColor(red: 253 / 255, green: 246 / 255, blue: 227 / 255, alpha: 1),
                padding: 5.0)

        }

    }
}

class DefaultEditorTheme: EditorThemeDelegate {}

// MARK: - Markdown
enum MDDefaultFontSize: CGFloat {
    case title1 = 24
    case title2 = 22
    case title = 20
    case normal = 16
    case small = 14
}

/// Solarized Theme
public extension MarkdownThemeDelegate {
    func loadDefaultStyles(colorScheme: MDColorScheme) -> MDSupportStyle {
        if colorScheme == .dark {
            return ThemeBuilder()
                .font(.mdDefault)
                .foregroundColor(MDColor(red: 101 / 255, green: 123 / 255, blue: 131 / 255, alpha: 1))
                .paragraph(lineHeight: 1.1)
                .build()
        } else {
            return ThemeBuilder()
                .font(.mdDefault)
                .foregroundColor(MDColor(red: 0, green: 43 / 255, blue: 54 / 255, alpha: 1))
                .paragraph(lineHeight: 1.5)
                .build()
        }
    }

    func loadHeadingStyles(_ defaultStyle: MDSupportStyle, level: Int) -> MDHeadingStyles {
        var fontSize: MDDefaultFontSize = .title
        switch level {
            case 1:
                fontSize = .title1
            case 2:
                fontSize = .title2

            default:
                break
        }

        return MDHeadingStyles(
            level: defaultStyle.withFontSize(.small).withGrayText(),
            plainText: defaultStyle.withFontSize(fontSize))
    }

    func loadCodeBlockStyles(_ defaultStyle: MDSupportStyle) -> MDCodeBlockStyles {
        let codeStyle = ThemeBuilder(from: defaultStyle)
            .font(.mdDefaultMono)
            .build()
        return MDCodeBlockStyles(language: defaultStyle.withItalics(), quote: defaultStyle.withGrayText(), plainText: codeStyle)
    }

    func loadInlineCodeStyles(_ defaultStyle: MDSupportStyle) -> MDInlineCodeStyles {
        let codeStyle = ThemeBuilder(from: defaultStyle)
            .font(MDFont.mdDefault)
            .build()
        return MDInlineCodeStyles(quote: defaultStyle.withGrayText(), code: codeStyle)
    }

    func loadLineBreakStyles(_ defaultStyle: MDSupportStyle) -> MDLineBreakStyles {
        return MDLineBreakStyles(plainText: defaultStyle.withFontSize(.small))
    }

    func loadBlockQuoteStyles(_ defaultStyle: MDSupportStyle) -> MDBlockQuoteStyles {
        return MDBlockQuoteStyles(symbol: defaultStyle.withGrayText(), plainText: defaultStyle.withItalics())
    }

    func loadEmphasisStyles(_ defaultStyle: MDSupportStyle, emphasisType: EmphasisType) -> MDEmphasisStyles {
        var builder = ThemeBuilder(from: defaultStyle)
        switch emphasisType {
            case .italic:
                builder = builder.font(MDFont.mdDefault.withItalics())
            case .strong:
                builder = builder.font(MDFont.mdDefault.withBold())
            case .strongAndItalic:
                builder = builder.font(MDFont.mdDefault.withBold().withItalics())
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
            .font(MDFont.monospacedSystemFont(ofSize: MDDefaultFontSize.normal.rawValue, weight: .thin))
            .build()
        return MDOrderedListStyles(index: defaultStyle.withGrayText(), plainText: plainTextStyle)
    }

    func loadTableStyles(_ defaultStyle: MDSupportStyle) -> MDTableStyles {
        return MDTableStyles(head: defaultStyle.withFontSize(.title).withBold(), item: defaultStyle, verticalDivider: defaultStyle.withGrayText(), horizontalDivider: defaultStyle.withGrayText())
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

fileprivate extension MDSupportStyle {
    func withGrayText() -> Self {
        var style = self
        style.foregroundColor = .lightGray
        return style
    }

    func withFontSize(_ size: MDDefaultFontSize) -> Self {
        return self.withFontSize(size.rawValue)
    }

}

class DefaultMarkdownTheme: MarkdownThemeDelegate {
}
