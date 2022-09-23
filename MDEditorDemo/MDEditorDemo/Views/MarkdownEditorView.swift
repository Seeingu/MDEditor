//
//  MarkdownEditorView.swift
//  MDEditorDemo
//
//  Created by seeu on 2022/9/17.
//

import SwiftUI

import SwiftUI
import MDEditor
import MDTheme
import MDCommon

class CustomThemeProvider: ThemeProvider, EditorThemeDelegate, MarkdownThemeDelegate {
    override init(_ colorScheme: MDColorScheme = .light) {
        super.init(colorScheme)
        self.editorThemeDelegate = self
        self.markdownThemeDelegate = self
    }
}

struct MarkdownEditorView: View {
    @State private var text: String = EXAMPLE_MARKDOWN_STRING

    @Environment(\.colorScheme) var colorScheme

    @State private var isEditable: Bool = true

    var customTheme: ThemeProvider {
        return CustomThemeProvider(colorScheme)
    }

    var body: some View {
        VStack {
            MDEditor(text: $text, isEditable: $isEditable)
                .theme(provider: customTheme)

        }
    }
}

struct MarkdownEditorView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditorView()
    }
}
