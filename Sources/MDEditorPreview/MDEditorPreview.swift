//
//  MDEditorPreview.swift
//  
//
//  Created by seeu on 2022/9/17.
//

import SwiftUI
import MDCommon

/// Use AttributedString(markdown:) directly
/// Has limited markdown support
public struct MDEditorAttributedStringPreview: View {
    @Binding var markdownText: String

    public init(markdownText: Binding<String>) {
        self._markdownText = markdownText
    }

    var text: AttributedString {
        do {
            return try AttributedString(markdown: markdownText)
        } catch {
            fatalError("load attributed string from markdown failed. \(error)")
        }

    }
    public var body: some View {
        Text(text)
    }
}

struct HeadingView: View {
    var text: String
    var body: some View {
        Text(text).bold()
    }
}

public struct MDEditorUIPreview: View {
    @Binding var markdownText: String

    public init(markdownText: Binding<String>) {
        self._markdownText = markdownText
    }

    var attrs: [MDSourceAttribute] {
        let parser = MDParser(markdownText)
        parser.parse()
        return parser.attrs
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(attrs) { attr in
                    switch attr.mdType {
                        case .heading(let mdHeading):
                            AnyView(HeadingView(text: mdHeading.plainText.0))
                        default:
                            Text(attr.plain)
                    }
                }
            }

        }
    }

}
