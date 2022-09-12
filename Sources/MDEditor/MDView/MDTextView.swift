//
//  MDTextView.swift
//
//
//  Created by seeu on 2022/9/6.
//

import AppKit
import MDTheme
import MDCommon

class MDTextView: NSView {
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

        // Colors support.
    var blockQuoteBackgroundColor: NSColor { .systemMint }

    var isEditable: Bool = true
    var themeProvider: ThemeProvider = ThemeProvider.default {
        didSet {
            // TODO: only need parse once
            updateMarkdownRender(string)
            relayout()
        }

    }
    internal var padding: CGFloat {
        CGFloat(themeProvider.editorStyles.padding)
    }

    internal var mdAttrs: [MDAttr] = []
    internal var blockQuoteRanges: [NSRange] = []

        // MARK: - attributeedString processing, markdown rendering
    var string: String = "" {
        didSet {
            textContentStorage.textStorage?.setAttributedString(NSAttributedString(string: string))
            setDefaultAttributes()
            updateMarkdownRender(string)
            relayout()
        }
    }

    private func setDefaultAttributes() {
        let documentNSRange = convertRange(from: textContentStorage.documentRange)
        textContentStorage.textStorage?.setAttributes(themeProvider.defaultMarkdownStyles.toAttributes(), range: documentNSRange)
    }

    internal func updateMarkdownRender(_ string: String) {
        let parser = MDParser(string)
        // TODO: parse modified part only
        parser.parse()
        mdAttrs = parser.attrs
        blockQuoteRanges = []
        for attr in mdAttrs {
            textContentStorage.textStorage?.invalidateAttributes(in: attr.range)
            var style: MDSupportStyle?
            switch attr.mdType {
                case .heading(let level):
                    style = themeProvider.headingStyle(level: level)
                case .blockQuote:
                    style = themeProvider.blockQuoteStyle()
                    blockQuoteRanges.append(attr.range)
                case .codeBlock:
                    style = themeProvider.codeBlockStyle()
                case .codeInline:
                    style = themeProvider.inlineCodeStyle()
                @unknown default:
                    style = themeProvider.defaultMarkdownStyles
            }
            // set background color of paragraph individually
            if style?.paragraph.backgroundColor != nil {
                print("background render")
                setParagraphBackgroundColor(in: attr.range)
            }
            textContentStorage.textStorage?.setAttributes(style!.toAttributes(), range: attr.range)
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

    internal func setParagraphBackgroundColor(in range: NSRange) {
        guard let textRange = convertRange(from: range) else {
            return
        }
        textLayoutManager.enumerateTextSegments(in: textRange, type: .highlight, options: []) { (_, frame, _, _) in
            var boundFrame = frame
                // TODO: use custom background setting
            boundFrame = boundFrame.insetBy(dx: 0, dy: -4 * 2)
            boundFrame.origin.x += padding
            let layer = MDBaseLayer()
            layer.backgroundColor = blockQuoteBackgroundColor.cgColor
            layer.frame = boundFrame
            backgroundLayer.addSublayer(layer)
            return true
        }
    }
        /// render text unrelated markdown style

        /// use hightlight frame to render highlight selection or caret
    internal func updateSelectionHighlights() {
        if !textLayoutManager.textSelections.isEmpty {
            selectionLayer.sublayers = nil
            for textSelection in textLayoutManager.textSelections {
                for textRange in textSelection.textRanges {
                    textLayoutManager.enumerateTextSegments(in: textRange,
                                                            type: .highlight,
                                                            options: []) {(_, textSegmentFrame, _, _) in
                        var highlightFrame = textSegmentFrame
                        highlightFrame.origin.x += padding
                        let highlight = MDBaseLayer()
                        if highlightFrame.size.width > 0 {
                            highlight.backgroundColor = themeProvider.editorStyles.selectionColor.cgColor
                        } else {
                            highlightFrame.size.width = 1 // fatten up the cursor
                            highlight.backgroundColor = themeProvider.editorStyles.caretColor.cgColor
                        }
                        highlight.frame = highlightFrame
                        selectionLayer.addSublayer(highlight)
                        return true
                    }
                }
            }
        }
    }

        // Live resize.
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        adjustViewportOffsetIfNeeded()
        updateContentSizeIfNeeded()
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

    func updateContentSizeIfNeeded() {
        let currentHeight = bounds.height
        var height: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.endLocation,
                                                       options: [.reverse, .ensuresLayout]) { layoutFragment in
            height = layoutFragment.layoutFragmentFrame.maxY
            return false
        }
        height = max(height, enclosingScrollView?.contentSize.height ?? 0)
        if abs(currentHeight - height) > 1e-10 {
            let contentSize = NSSize(width: self.bounds.width, height: height)
            setFrameSize(contentSize)
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

    private func updateTextContainerSize() {
        let textContainer = textLayoutManager.textContainer
        if textContainer != nil && textContainer!.size.width != bounds.width {
            textContainer!.size = NSSize(width: bounds.size.width, height: 0)
            relayout()
        }
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
