//
//  MDTextViewController.swift
//  
//
//  Created by seeu on 2022/9/6.
//

#if os(macOS)
import AppKit
public typealias MDViewController = NSViewController
typealias MDScrollView = NSScrollView
#else
import UIKit
public typealias MDViewController = UIViewController
typealias MDScrollView = UIScrollView
#endif
import SwiftUI
import MDTheme

public class MDTextViewController: MDViewController, NSTextContentManagerDelegate, NSTextContentStorageDelegate, MDTextViewDelegate {
    private var textContentStorage: NSTextContentStorage
    private var textLayoutManager: NSTextLayoutManager
    private var textDocumentView: MDTextView!

    public var text: String {
        didSet {
            textDocumentView.string = text
        }
    }
    public var isEditable: Bool {
        didSet {
            textDocumentView.isEditable = isEditable
        }
    }
    public var themeProvider: ThemeProvider {
        didSet {
            textDocumentView.themeProvider = themeProvider
            themeProvider.reloadEditorStyles()
        }
    }
    required init?(coder: NSCoder) {
        fatalError()
    }

    public init(text: String, isEditable: Bool, themeProvider: ThemeProvider) {
        textLayoutManager = NSTextLayoutManager()
        textContentStorage = NSTextContentStorage()
        self.text = text
        self.isEditable = isEditable
        self.themeProvider = themeProvider
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(model: MDModel) {
        self.init(text: model.text, isEditable: model.isEditable, themeProvider: model.themeProvider)
    }

    public override func loadView() {
        let textView = MDTextView(frame: .zero)
        textView.textContentStorage = textContentStorage
        textView.textLayoutManager = textLayoutManager
        textView.isEditable = isEditable
        textView.string = text

        textContentStorage.addTextLayoutManager(textLayoutManager)

        let textContainer = NSTextContainer(size: .zero)
        textLayoutManager.textContainer = textContainer

        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false

        #if os(macOS)
        let scrollView = MDScrollView()

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.autoresizingMask = [.width, .height]

        // TODO: use clipview as content view of scrollview
        let clipView = NSClipView()
        clipView.translatesAutoresizingMaskIntoConstraints = false
        clipView.autoresizingMask = [.width, .height]

        scrollView.documentView = textView
//        scrollView.contentView = clipView
        self.textDocumentView = textView
        self.view = scrollView
        #else
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.view = textView
        self.textDocumentView = textView

        #endif

    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

}
