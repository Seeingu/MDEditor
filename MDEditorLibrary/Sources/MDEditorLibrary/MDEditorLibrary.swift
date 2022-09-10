//
//  MDEditor.swift
//
//
//  Created by seeu on 2022/9/6.
//

import SwiftUI

public struct MDEditor: NSViewControllerRepresentable {
    @Binding private var text: String
    @Binding private var isEditable: Bool
    public typealias NSViewControllerType = MDTextViewController

    public init(text: Binding<String>, isEditable: Binding<Bool>) {
        self._text = text
        self._isEditable = isEditable
    }

    public func makeNSViewController(context: Context) -> NSViewControllerType {
        let controller = NSViewControllerType(text: text, isEditable: isEditable)
        return controller
    }

    public func updateNSViewController(_ nsViewController: MDTextViewController, context: Context) {
        nsViewController.text = text
        nsViewController.isEditable = isEditable
    }
}
