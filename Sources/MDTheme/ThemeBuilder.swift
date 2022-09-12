//
//  ThemeBuilder.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import AppKit
import MDCommon

internal class ThemeBuilder {
    static let defaultStyle = ThemeBuilder()
        .font(NSFont.monospacedSystemFont(ofSize: 20, weight: .regular))
        .paragraph(lineHeight: 1.1)
        .build()

    private var style = MDSupportStyle()

    init() {}

    init(from s: MDSupportStyle) {
        style.font = s.font
        style.paragraph = s.paragraph
        style.foregroundColor = s.foregroundColor
        style.backgroundColor = s.backgroundColor
    }

    func paragraph(lineHeight: Float = 1.1, backgroundColor: NSColor? = nil) -> Self {
        style.paragraph.lineHeight = lineHeight
        style.paragraph.backgroundColor = backgroundColor
        return self
    }

    func font(_ value: NSFont) -> Self {
        style.font = value
        return self
    }

    func foregroundColor(_ value: NSColor?) -> Self {
        style.foregroundColor = value
        return self
    }

    func backgroundColor(_ value: NSColor?) -> Self {
        style.backgroundColor = value
        return self
    }

    func build() -> MDSupportStyle {
        self.style
    }
}

extension MDSupportStyle {
    public func toAttributes() -> StringAttributes {
        let p = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        p.lineHeightMultiple = CGFloat(paragraph.lineHeight)

        var attr: StringAttributes = [
            .paragraphStyle: p,
            .font: font
        ]
        if foregroundColor != nil {
           attr[.foregroundColor] = foregroundColor
        }
        if backgroundColor != nil {
            attr[.backgroundColor] = backgroundColor
        }
        return attr
    }
}
