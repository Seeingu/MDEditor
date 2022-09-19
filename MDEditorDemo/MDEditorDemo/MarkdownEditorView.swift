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

    func loadEditorStyles(_ defaultStyles: EditorStyles) -> EditorStyles {
        var style = defaultStyles
        if colorScheme == .dark {
            style.editorBackground = MDColor(hue: 215 / 255, saturation: 0.15, brightness: 0.22, alpha: 1.0)
        } else {
            style.caretColor = .blue
        }
        style.padding = 20
        return style
    }
}

struct MarkdownEditorView: View {
    @State private var text: String = """
    # title

    markdown _text_, **bold**, ***bold and italic***, ~~deleted~~

    ---

    ## title2

    > Dorothy followed her through many of the beautiful rooms in her castle.

    1. First item
    2. Second item
    3. Third item
        1. Indented item
        2. Indented item
    4. Fourth item

    `code` [Duck Duck Go](https://duckduckgo.com)

    - [x] finished
    - [ ] todo

    - item1, _inlineStyle_
    - item2

    ```js
    let a = 1;
    ```

    | Syntax      | Description |
    | ----------- | ----------- |
    | Header      | Title       |
    | Paragraph   | Text        |

    ![Image](https://via.placeholder.com/150)



    """

    @Environment(\.colorScheme) var colorScheme

    @State private var isEditable: Bool = true

    var customTheme: ThemeProvider {
        let mdColorScheme: MDColorScheme = colorScheme == .dark ? .dark : .light
        return CustomThemeProvider(mdColorScheme)
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
