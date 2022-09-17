//
//  ContentView.swift
//  MDEditorDemo
//
//  Created by seeu on 2022/9/6.
//

import SwiftUI
import MDEditor
import MDTheme
import MDCommon

struct ContentView: View {
    let navigationItems = [(0, "editor"), (1, "preview")]
    @State private var selection: Int = 0
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(navigationItems, id: \.0) { item in
                    Text(item.1)
                }
            }
        } detail: {
            if selection == 0 {
                MarkdownEditorView()
            } else {
                MarkdownPreview()
            }

        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
