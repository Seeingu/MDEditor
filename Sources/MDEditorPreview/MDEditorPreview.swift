//
//  MDEditorPreview.swift
//  
//
//  Created by seeu on 2022/9/17.
//

import SwiftUI
import Markdown
import WebKit

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
