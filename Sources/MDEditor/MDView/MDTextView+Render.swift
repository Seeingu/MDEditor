//
//  MDTextView+Render.swift
//  
//
//  Created by seeu on 2022/9/12.
//

import Foundation
import MDTheme
import MDCommon
import QuartzCore

extension MDTextView {
    internal func animate(_ layer: CALayer, from source: CGPoint, to destination: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = source
        animation.toValue = destination
        animation.duration = 0.3
        layer.add(animation, forKey: nil)
    }

    internal func updateTextContainerSize() {
        let textContainer = textLayoutManager.textContainer

        if textContainer != nil && textContainer!.size.width != bounds.width {
            textContainer!.size = CGSize(width: bounds.size.width, height: 0)
            relayout()
        }
    }
    internal func updateContentSizeIfNeeded() {
        let currentHeight = bounds.height
        var height: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.endLocation,
                                                        options: [.reverse, .ensuresLayout]) { layoutFragment in
            height = layoutFragment.layoutFragmentFrame.maxY
            return false // stop
        }
        #if os(macOS)
        height = max(height, enclosingScrollView?.contentSize.height ?? 0)
        if abs(currentHeight - height) > 1e-10 {
            let contentSize = NSSize(width: self.bounds.width, height: height)
            setFrameSize(contentSize)
        }
        #else
        height = max(height, contentSize.height)
        if abs(currentHeight - height) > 1e-10 {
            let contentSize = CGSize(width: self.bounds.width, height: height)
            self.contentSize = contentSize
        }

        #endif
    }

    internal func setDefaultAttributes() {
        let documentNSRange = convertRange(from: textContentStorage.documentRange)
        textContentStorage.textStorage?.setAttributes(themeProvider.defaultMarkdownStyles.toAttributes(), range: documentNSRange)
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
                // TODO: use theme's paragraph backgroundColor
            var blockQuoteBackgroundColor: MDColor = .systemMint
            layer.backgroundColor = blockQuoteBackgroundColor.cgColor
            layer.frame = boundFrame
            backgroundLayer.addSublayer(layer)
            return true
        }
    }

    /// render markdown content
    internal func updateMarkdownRender(_ string: String) {
        let parser = MDParser(string)
            // TODO: parse modified part only
        parser.parse()
        mdAttrs = parser.attrs
        for attr in mdAttrs {
            textContentStorage.textStorage?.invalidateAttributes(in: attr.range)
            var style: MDSupportStyle?
            switch attr.mdType {
                case .heading(let level):
                    style = themeProvider.headingStyle(level: level)
                case .blockQuote:
                    style = themeProvider.blockQuoteStyle()
                case .codeBlock:
                    style = themeProvider.codeBlockStyle()
                case .codeInline:
                    style = themeProvider.inlineCodeStyle()
                @unknown default:
                    style = themeProvider.defaultMarkdownStyles
            }
                // set background color of paragraph individually
            if style?.paragraph.backgroundColor != nil {
                setParagraphBackgroundColor(in: attr.range)
            }
            textContentStorage.textStorage?.setAttributes(style!.toAttributes(), range: attr.range)
        }
    }

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
}
