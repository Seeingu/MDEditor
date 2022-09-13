# MDEditor (In development)

Markdown editor and viewer in Swift, text rendering and processing by using Textkit2, 
and use swift-markdown as markdown-gfm parsing tool

Support platform:
- macOS >12
- iOS >15.6 (iOS 16.0 feature used: [UIEditMenuInteraction](https://developer.apple.com/documentation/uikit/uieditmenuinteraction))


## Usage

```swift
import SwiftUI
import MDEditor

struct ContentView: View {
    @State private var text: String = """
    # Title

    paragraph
    """

    @State private var isEditable: Bool = true

    var body: some View {
        ZStack {
            MDEditor(text: $text, isEditable: $isEditable)
        }
    }
}
```

## Inspiration

- The [Meet Textkit2](https://developer.apple.com/videos/play/wwdc2021/10061/) talk gives explanation of how text rendered and processed, and the details about how to use Textkit2

- [STTextView](https://github.com/krzyzanowskim/STTextView) implemented the code editor view based on Textkit2

# License

Apache v2
