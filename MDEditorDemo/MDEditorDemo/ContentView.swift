//
//  ContentView.swift
//  MDEditorDemo
//
//  Created by seeu on 2022/9/6.
//

import SwiftUI
import MDEditor

struct ContentView: View {
    @State private var text: String = """
    # title

    markdown text

    # title2

    > Dorothy followed her through many of the beautiful rooms in her castle.

    1. First item
    2. Second item
    3. Third item
        1. Indented item
        2. Indented item
    4. Fourth item

    `code` [Duck Duck Go](https://duckduckgo.com)

    ```js
    let a = 1;
    ```

    ![Image](https://via.placeholder.com/150)


    """

    @State private var isEditable: Bool = true

    var body: some View {
        ZStack {
            MDEditor(text: $text, isEditable: $isEditable)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
