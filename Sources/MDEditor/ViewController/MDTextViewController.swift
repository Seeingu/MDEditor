//
//  MDTextViewController.swift
//  
//
//  Created by seeu on 2022/9/6.
//

#if os(macOS)
import AppKit
public typealias MDViewController = NSViewController

#else
import UIKit
public typealias MDViewController = UIViewController

#endif
import SwiftUI
import MDTheme

public class MDTextViewController: MDViewController {
    var delegate: MDTextViewControlDelegate?
    private var textContentStorage: NSTextContentStorage
    private var textLayoutManager: NSTextLayoutManager
    private var textDocumentView: MDTextView!
    private var model: MDModel
    #if os(macOS)
    private var scrollView: NSScrollView?
    private var textFinder = NSTextFinder()
    #endif

    required init?(coder: NSCoder) {
        fatalError()
    }

//    public init(text: Binding<String>, isEditable: Bool, themeProvider: ThemeProvider) {
//        textLayoutManager = NSTextLayoutManager()
//        textContentStorage = NSTextContentStorage()
//        self.text = text
//        self.isEditable = isEditable
//        self.themeProvider = themeProvider
//        super.init(nibName: nil, bundle: nil)
//    }

    init(model: MDModel) {
                textLayoutManager = NSTextLayoutManager()
        textContentStorage = NSTextContentStorage()

        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    func updateView(model: MDModel) {
        textDocumentView.setString(model.text)
        textDocumentView.isEditable = model.isEditable
        textDocumentView.themeProvider = model.themeProvider

    }

    public override func loadView() {
        let textView = MDTextView(frame: .zero)
        textView.textContentStorage = textContentStorage
        textView.textLayoutManager = textLayoutManager
        textView.isEditable = model.isEditable
        textView.textViewDelegate = self

        textContentStorage.addTextLayoutManager(textLayoutManager)

        let textContainer = NSTextContainer(size: .zero)
        textLayoutManager.textContainer = textContainer

        textView.setString(model.text)

        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false

        #if os(macOS)
        let scrollView = NSScrollView()

        self.scrollView = scrollView
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

        textFinder.client = textView
        textFinder.findBarContainer = scrollView
        textView.textFinder = textFinder

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

extension MDTextViewController: MDTextViewDelegate {
    public func onTextChange(_ text: String) {
        model.textChangeAction?(text)
        self.delegate?.textViewDidChange(textDocumentView)
    }
}

protocol MDTextViewControlDelegate {
    func textViewDidChange(_ textView: MDTextView)
}
