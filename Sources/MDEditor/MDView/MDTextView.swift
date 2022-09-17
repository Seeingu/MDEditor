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
    internal var stateModel = MDTextViewStateModel()

    private var boundsDidChangeObserver: NSObjectProtocol?

        /// use left top coordination
    override var isFlipped: Bool { true }

        // MARK: - init & deinit
    required init?(coder: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        autoresizingMask = [.width, .height]

        initLayers()
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
    internal var stateModel = MDTextViewStateModel()

    let selectionColor = UIColor.systemBlue
    let caretColor = UIColor.tintColor

    // UIEditMenuInteraction only available in iOS >16
    // TODO: update type identifier after iOS 16 released
    internal var editMenuInteraction: Any!

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

    override init(frame: CGRect) {

        super.init(frame: frame)
        initLayers()

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

extension MDTextView {
    internal var lines: [MDSourceLineInfo] {
        get {
            stateModel.lines
        }
        set {
            stateModel.lines = newValue
        }
    }

    public var textViewDelegate: MDTextViewDelegate? {
        set {
            stateModel.textViewDelegate = newValue
        }
        get {
            stateModel.textViewDelegate
        }
    }

    internal var textLayoutManager: NSTextLayoutManager! {
        set {
            stateModel.textLayoutManager = newValue
            stateModel.textLayoutManager.delegate = self
            stateModel.textLayoutManager.textViewportLayoutController.delegate = self
        }
        get {
            stateModel.textLayoutManager
        }
    }

    internal var textContentStorage: NSTextContentStorage! {
        get {
            stateModel.textContentStorage
        }
        set {
            stateModel.textContentStorage = newValue
        }
    }

    var themeProvider: ThemeProvider {
        get {
            stateModel.themeProvider
        }
        set {
            stateModel.themeProvider = newValue
            updateMarkdownRender(string)
        }
    }

    internal var padding: CGFloat {
        get {
            CGFloat(themeProvider.editorStyles.padding)
        }
    }

    var string: String {
        get {
            textContentStorage.textStorage?.string ?? ""
        }
    }

    internal var contentLayer: CALayer! {
        get {
            stateModel.contentLayer
        }
        set {
            stateModel.contentLayer = newValue
        }
    }
    internal var selectionLayer: CALayer! {
        get {
            stateModel.selectionLayer
        }
        set {
            stateModel.selectionLayer = newValue
        }
    }
    internal var backgroundLayer: CALayer! {
        get {
            stateModel.backgroundLayer
        }
        set {
            stateModel.backgroundLayer = newValue
        }
    }
    internal var fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer>! {
        get {
            stateModel.fragmentLayerMap
        }
        set {
            stateModel.fragmentLayerMap = newValue
        }
    }

    public var isEditable: Bool {
        get {
            stateModel.isEditable
        }
        set {
            stateModel.isEditable = newValue
        }
    }

    internal var mdAttrs: [MDSourceAttribute] {
        get {
            stateModel.mdAttrs
        }
        set {
            stateModel.mdAttrs = newValue
        }
    }

    internal func initLayers() {
        fragmentLayerMap = .weakToWeakObjects()
        #if os(macOS)
        guard let layer = layer else { return }
        #endif
        layer.backgroundColor = themeProvider.editorStyles.editorBackground.cgColor

        selectionLayer = MDBaseLayer()
        contentLayer = MDBaseLayer()
        backgroundLayer = MDBaseLayer()
        #if os(macOS)
        selectionLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        contentLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        backgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        #endif

        layer.addSublayer(backgroundLayer)
        layer.addSublayer(contentLayer)
            // set selection layer on top
        layer.addSublayer(selectionLayer)
    }

    private func restoreCaretLocation(action: () -> Void) {
        let location = textLayoutManager.firstSelection?.textRanges.first?.location

        action()
        changeCaretPosition(in: NSTextRange(location: location ?? textLayoutManager.documentRange.location))
    }

    public func setString(_ string: String) {
        restoreCaretLocation {
            textContentStorage.textStorage?.setAttributedString(NSAttributedString(string: string))
        }

        updateLineInfo(string)
        updateMarkdownRender(string)
        relayout()
    }

}
