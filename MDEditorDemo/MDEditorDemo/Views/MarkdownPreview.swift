//
//  MarkdownPreview.swift
//  MDEditorDemo
//
//  Created by seeu on 2022/9/17.
//

import SwiftUI
import MDEditorPreview

struct MarkdownPreview: View {
    @State var markdown: String = EXAMPLE_MARKDOWN_STRING
    var body: some View {
        MDEditorAttributedStringPreview(markdownText: $markdown)
    }
}

struct MDPreview_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownPreview()
    }
}
