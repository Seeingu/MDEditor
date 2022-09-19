//
//  MDEditor.swift
//
//
//  Created by seeu on 2022/9/6.
//

import SwiftUI
import MDTheme

#if os(macOS)
public struct MDEditor: NSViewControllerRepresentable {
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

   private var model = MDModel()
    @Binding private var text: String
    @Binding private var isEditable: Bool
    public typealias NSViewControllerType = MDTextViewController

    public init(text: Binding<String>, isEditable: Binding<Bool>, onTextChange: ((_ text: String) -> Void)? = nil) {
        self._text = text
        self._isEditable = isEditable
        model.text = text.wrappedValue

        model.isEditable = isEditable.wrappedValue
        model.textChangeAction = onTextChange
    }

    public func makeNSViewController(context: Context) -> NSViewControllerType {
        let controller = NSViewControllerType(model: model)
        controller.delegate = context.coordinator

        return controller
    }

    public func updateNSViewController(_ nsViewController: MDTextViewController, context: Context) {
        model.text = text
        model.isEditable = isEditable
        nsViewController.updateView(model: model)
    }
}

#else
public struct MDEditor: UIViewControllerRepresentable {
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private var model = MDModel()
    @Binding private var text: String
    @Binding private var isEditable: Bool
    public typealias UIViewControllerType = MDTextViewController

    public init(text: Binding<String>, isEditable: Binding<Bool>, onTextChange: ((_ text: String) -> Void)? = nil) {
        self._text = text
        self._isEditable = isEditable
        model.text = text.wrappedValue
        model.isEditable = isEditable.wrappedValue
        model.textChangeAction = onTextChange
    }

    public func makeUIViewController(context: Context) -> MDTextViewController {
        let controller = UIViewControllerType(model: model)
        controller.delegate = context.coordinator
        return controller
    }

    public func updateUIViewController(_ uiViewController: MDTextViewController, context: Context) {
        uiViewController.updateView(model: model)
    }

}
#endif

// MARK: - SwiftUI View extension
extension MDEditor {
    public func theme(provider: ThemeProvider) -> some View {
        self.model.themeProvider = provider

        return self
    }
}

// MARK: - Coordinator
extension MDEditor {
    public class Coordinator: NSObject, MDTextViewControllDelegate {
        var parent: MDEditor

        init(_ parent: MDEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: MDTextView) {
            parent.text = textView.mdString
        }

    }

}
