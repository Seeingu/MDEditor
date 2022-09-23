//
//  ThemeBuilder.swift
//  
//
//  Created by seeu on 2022/9/11.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import MDCommon

/// internal theme builder
internal class ThemeBuilder {
    private var style = MDSupportStyle()

    init() {}

    init(from s: MDSupportStyle) {
        style.font = s.font
        style.paragraph = s.paragraph
        style.foregroundColor = s.foregroundColor
        style.backgroundColor = s.backgroundColor
    }

    func paragraph(lineHeight: Float = 1.1, backgroundColor: MDColor? = nil) -> Self {
        style.paragraph.lineHeight = lineHeight
        style.paragraph.backgroundColor = backgroundColor
        return self
    }

    func font(_ value: MDFont) -> Self {
        style.font = value
        return self
    }

    func foregroundColor(_ value: MDColor?) -> Self {
        style.foregroundColor = value
        return self
    }

    func backgroundColor(_ value: MDColor?) -> Self {
        style.backgroundColor = value
        return self
    }

    func link() -> Self {
        style.isLink = true
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
