//
//  MarkdownPreview.swift
//  MDEditorDemo
//
//  Created by seeu on 2022/9/17.
//

import SwiftUI
import MDEditorPreview

struct MarkdownPreview: View {
    @State var markdown: String = "# title \n\n ## title \n\n *bold*"
    var body: some View {
        MDEditorAttributedStringPreview(markdownText: $markdown)
    }
}

struct MDPreview_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownPreview()
    }
}
