//
//  MDTextView.swift
//
//
//  Created by seeu on 2022/9/6.
//

import MDTheme
import MDCommon
#if os(macOS)
// MARK: - mac
import AppKit

class MDTextView: NSView {
    internal var lines: [MDSourceLineInfo] = []
    var textLayoutManager: NSTextLayoutManager! {
        didSet {
            if let tlm = textLayoutManager {
                tlm.delegate = self
                tlm.textViewportLayoutController.delegate = self
            }
        }
    }

    var textContentStorage: NSTextContentStorage!

        // MARK: - style config

    var isEditable: Bool = true

    internal var mdAttrs: [MDSourceAttribute] = []
    var themeProvider: ThemeProvider = ThemeProvider.default {
        didSet {
            updateMarkdownRender(string)
        }
    }

    internal var padding: CGFloat {
        CGFloat(themeProvider.editorStyles.padding)
    }

        // MARK: - attributeedString processing, markdown rendering
    var string: String = "" {
        didSet {
            textContentStorage.textStorage?.setAttributedString(NSAttributedString(string: string))
            setDefaultAttributes()
            updateLineInfo(string)
            updateMarkdownRender(string)
        }
    }

    private var boundsDidChangeObserver: NSObjectProtocol?

    internal var contentLayer: CALayer! = nil
    internal var selectionLayer: CALayer! = nil
    internal var backgroundLayer: CALayer! = nil
    internal var fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer>

        /// use left top coordination
    override var isFlipped: Bool { true }

        // MARK: - init & deinit
    required init?(coder: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        fragmentLayerMap = .weakToWeakObjects()
        super.init(frame: frame)
        wantsLayer = true
        autoresizingMask = [.width, .height]

        layer?.backgroundColor = themeProvider.editorStyles.editorBackground.cgColor

        selectionLayer = MDBaseLayer()
        selectionLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        contentLayer = MDBaseLayer()
        contentLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        backgroundLayer = MDBaseLayer()
        backgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

        layer?.addSublayer(backgroundLayer)
        layer?.addSublayer(contentLayer)
            // set selection layer on top
        layer?.addSublayer(selectionLayer)
    }

    deinit {
        if let observer = boundsDidChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

        /// first responder
    override var acceptsFirstResponder: Bool { return true }

        /// Responsive scrolling.
    override class var isCompatibleWithResponsiveScrolling: Bool { return true }
    override func prepareContent(in rect: NSRect) {
        relayout()
        super.prepareContent(in: rect)
    }

        // Live resize.
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        adjustViewportOffsetIfNeeded()
        updateContentSizeIfNeeded()
        updateMarkdownRender(string)
    }

        // Scroll view support.
    private var scrollView: NSScrollView? {
        guard let result = enclosingScrollView else { return nil }
        if result.documentView == self {
            return result
        } else {
            return nil
        }
    }

    internal func adjustViewportOffsetIfNeeded() {
        let viewportLayoutController = textLayoutManager.textViewportLayoutController
        let contentOffset = scrollView!.contentView.bounds.minY
        if contentOffset < scrollView!.contentView.bounds.height &&
            viewportLayoutController.viewportRange!.location.compare(textLayoutManager.documentRange.location) == .orderedDescending {
                // Nearing top, see if we need to adjust and make room above.
            adjustViewportOffset()
        } else if viewportLayoutController.viewportRange!.location.compare(textLayoutManager.documentRange.location) == .orderedSame {
                // At top, see if we need to adjust and reduce space above.
            adjustViewportOffset()
        }
    }

    private func adjustViewportOffset() {
        let viewportLayoutController = textLayoutManager.textViewportLayoutController
        var layoutYPoint: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(from: viewportLayoutController.viewportRange!.location,
                                                       options: [.reverse, .ensuresLayout]) { layoutFragment in
            layoutYPoint = layoutFragment.layoutFragmentFrame.origin.y
            return true
        }
        if layoutYPoint != 0 {
            let adjustmentDelta = bounds.minY - layoutYPoint
            viewportLayoutController.adjustViewport(byVerticalOffset: adjustmentDelta)
            scroll(CGPoint(x: scrollView!.contentView.bounds.minX, y: scrollView!.contentView.bounds.minY + adjustmentDelta))
        }
    }

    override func viewWillMove(toSuperview newSuperview: NSView?) {
        let clipView = scrollView?.contentView
        if clipView != nil {
            NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: clipView)
        }

        super.viewWillMove(toSuperview: newSuperview)
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()

        let clipView = scrollView?.contentView
        if clipView != nil {
            boundsDidChangeObserver = NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification,
                                                                             object: clipView,
                                                                             queue: nil) { [weak self] _ in
                self?.relayout()
            }
        }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateTextContainerSize()
    }

        // Center Selection
    override func centerSelectionInVisibleArea(_ sender: Any?) {
        if !textLayoutManager.textSelections.isEmpty {
            let viewportOffset =
            textLayoutManager.textViewportLayoutController.relocateViewport(to: textLayoutManager.textSelections[0].textRanges[0].location)
            scroll(CGPoint(x: 0, y: viewportOffset))
        }
    }

}

#else
// MARK: iOS
import UIKit

class MDTextView: UIScrollView, UIGestureRecognizerDelegate {
    internal var lines: [MDSourceLineInfo] = []

    let selectionColor = UIColor.systemBlue
    let caretColor = UIColor.tintColor

    var isEditable: Bool = true

    // UIEditMenuInteraction only available in iOS >16
    // TODO: update type identifier after iOS 16 released
    internal var editMenuInteraction: Any!

    var string: String = "" {
        didSet {
            textContentStorage.textStorage?.setAttributedString(NSAttributedString(string: string))
            setDefaultAttributes()
            updateMarkdownRender(string)
        }
    }

    internal var contentLayer: CALayer! = nil
    internal var selectionLayer: CALayer! = nil
    internal var backgroundLayer: CALayer! = nil
    internal var fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer>
    internal var padding: CGFloat {
        CGFloat(themeProvider.editorStyles.padding)
    }

    internal var mdAttrs: [MDSourceAttribute] = []
    var themeProvider: ThemeProvider = ThemeProvider.default {
        didSet {
            updateMarkdownRender(string)
        }
    }

        // MARK: - NSTextViewportLayoutControllerDelegate

    internal func adjustViewportOffsetIfNeeded() {
        let viewportLayoutController = textLayoutManager.textViewportLayoutController
        let contentOffset = bounds.minY
        if contentOffset < bounds.height &&
            viewportLayoutController.viewportRange!.location.compare(textLayoutManager.documentRange.location) == .orderedDescending {
                // Nearing top, see if we need to adjust and make room above.
            adjustViewportOffset()
        } else if viewportLayoutController.viewportRange!.location.compare(textLayoutManager.documentRange.location) == .orderedSame {
                // At top, see if we need to adjust and reduce space above.
            adjustViewportOffset()
        }
    }

    internal func adjustViewportOffset() {
        let viewportLayoutController = textLayoutManager!.textViewportLayoutController
        var layoutYPoint: CGFloat = 0
        textLayoutManager!.enumerateTextLayoutFragments(from: viewportLayoutController.viewportRange!.location,
                                                        options: [.reverse, .ensuresLayout]) { layoutFragment in
            layoutYPoint = layoutFragment.layoutFragmentFrame.origin.y
            return true
        }
        if layoutYPoint != 0 {
            let adjustmentDelta = bounds.minY - layoutYPoint
            viewportLayoutController.adjustViewport(byVerticalOffset: adjustmentDelta)
            let point = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + adjustmentDelta)
            setContentOffset(point, animated: true)
        }
    }

    var textLayoutManager: NSTextLayoutManager! {
        didSet {
            if let tlm = textLayoutManager {
                tlm.delegate = self
                tlm.textViewportLayoutController.delegate = self
            }
        }
    }
    var textContentStorage: NSTextContentStorage!

    override init(frame: CGRect) {
        fragmentLayerMap = .weakToWeakObjects()

        super.init(frame: frame)
        layer.backgroundColor = UIColor.white.cgColor
        selectionLayer = MDBaseLayer()
        contentLayer = MDBaseLayer()
        backgroundLayer = MDBaseLayer()
        layer.addSublayer(selectionLayer)
        layer.addSublayer(contentLayer)
        layer.addSublayer(backgroundLayer)

        translatesAutoresizingMaskIntoConstraints = false

        addGestureRecognizers()

            // Add the edit menu interaction.
        if #available(iOS 16.0, *) {
            editMenuInteraction = UIEditMenuInteraction(delegate: self)
            self.addInteraction(editMenuInteraction as! UIEditMenuInteraction)
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

}

#endif
