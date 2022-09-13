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
    @ObservedObject private var model = MDModel()
    @Binding private var text: String
    @Binding private var isEditable: Bool
    public typealias NSViewControllerType = MDTextViewController

    public init(text: Binding<String>, isEditable: Binding<Bool>) {
        self._text = text
        self._isEditable = isEditable
    }

    public func makeNSViewController(context: Context) -> NSViewControllerType {
        let controller = NSViewControllerType(text: text, isEditable: isEditable, themeProvider: model.themeProvider)
        return controller
    }

    public func updateNSViewController(_ nsViewController: MDTextViewController, context: Context) {
        nsViewController.themeProvider = model.themeProvider
    }
}

#else
public struct MDEditor: UIViewControllerRepresentable {
    @ObservedObject private var model = MDModel()
    @Binding private var text: String
    @Binding private var isEditable: Bool
    public typealias UIViewControllerType = MDTextViewController

    public init(text: Binding<String>, isEditable: Binding<Bool>) {
        self._text = text
        self._isEditable = isEditable
    }

    public func makeUIViewController(context: Context) -> MDTextViewController {
        let controller = UIViewControllerType(text: text, isEditable: isEditable, themeProvider: model.themeProvider)
        return controller
    }

    public func updateUIViewController(_ uiViewController: MDTextViewController, context: Context) {
        uiViewController.themeProvider = model.themeProvider
    }
}
#endif

extension MDEditor {
    public func theme(provider: ThemeProvider) -> some View {
        self.model.themeProvider = provider

        return self
    }
}
