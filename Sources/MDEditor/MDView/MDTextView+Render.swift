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

    // FIXME: paragraph frame position is inaccurate
    internal func setParagraphBackgroundColor(in range: NSRange, color: MDColor) {
        guard let textRange = convertRange(from: range) else {
            return
        }
        backgroundLayer.sublayers = nil
        textLayoutManager.enumerateTextSegments(in: textRange, type: .highlight, options: []) { (_, frame, _, _) in
            var boundFrame = frame
                // TODO: render block in rectable
            boundFrame = boundFrame.insetBy(dx: 0, dy: 0)
            boundFrame.origin.x += padding
            let layer = MDBaseLayer()
            layer.backgroundColor = color.cgColor
            layer.frame = boundFrame
            backgroundLayer.addSublayer(layer)
            return true
        }

    }

    internal func updateEditorRender() {
        themeProvider.reloadEditorStyles()
        viewLayer.backgroundColor = themeProvider.editorStyles.editorBackground.cgColor
        relayout()
    }

    /// render markdown content
    internal func updateMarkdownRender(_ string: String) {
        let parser = MDParser(string, lines: lines)
            // TODO: incremental parsing
        parser.parse()
        mdAttrs = parser.attrs
        for attr in mdAttrs {
            // invalidate and set default styles
            textContentStorage.textStorage?.invalidateAttributes(in: attr.range)
            textContentStorage.textStorage?.setAttributes(themeProvider.defaultMarkdownStyles.toAttributes(), range: attr.range)

            var attributes: [(MDSupportStyle, NSRange)] = []
            var additionalStringAttributes: [(StringAttributes, NSRange)] = []
            switch attr.mdType {
                case .heading(let mdHeading):
                    let headingStyle = themeProvider.headingStyle(level: mdHeading.level.0)
                    attributes.append((headingStyle.level, makeRange(line: mdHeading.startLine, range: mdHeading.level.range)))
                    attributes.append((headingStyle.plainText, makeRange(line: mdHeading.startLine, range: mdHeading.plainText.range)))
                case .blockQuote(let mdBlockQuote):
                    let blockQuoteStyle = themeProvider.blockQuoteStyle()
                    var line = mdBlockQuote.startLine
                    for block in mdBlockQuote.blocks {
                        attributes.append((blockQuoteStyle.symbol, makeRange(line: line, range: block.symbol.range)))
                        attributes.append((blockQuoteStyle.plainText, makeRange(line: line, range: block.plainText.range)))
                        line += 1
                    }

                case .codeBlock(let mdCodeBlock):
                    let codeBlockStyle = themeProvider.codeBlockStyle()
                    attributes.append((codeBlockStyle.plainText, makeRange(line: mdCodeBlock.startLine, range: mdCodeBlock.plainText.range)))
                    attributes.append((codeBlockStyle.quote, makeRange(line: mdCodeBlock.startLine, range: mdCodeBlock.startSymbol.range)))
                    attributes.append((codeBlockStyle.quote, makeRange(line: mdCodeBlock.startLine, range: mdCodeBlock.endSymbol.range)))
                    if mdCodeBlock.language != nil {
                        attributes.append((codeBlockStyle.language, makeRange(line: mdCodeBlock.startLine, range: mdCodeBlock.language!.range)))
                    }
                case .codeInline(let mdInlineCode):
                    let inlineCodeStyle = themeProvider.inlineCodeStyle()
                    attributes.append((inlineCodeStyle.code, makeRange(line: mdInlineCode.startLine, range: mdInlineCode.plainText.range)))
                    attributes.append((inlineCodeStyle.quote, makeRange(line: mdInlineCode.startLine, range: mdInlineCode.startSymbol.range)))
                    attributes.append((inlineCodeStyle.quote, makeRange(line: mdInlineCode.startLine, range: mdInlineCode.endSymbol.range)))
                case .emphasis(let mdEmphasis):
                    let emphasisStyle = themeProvider.emphasisStyle(emphasisType: mdEmphasis.type)
                    attributes.append((emphasisStyle.symbol, makeRange(line: mdEmphasis.startLine, range: mdEmphasis.startSymbol.range)))
                    attributes.append((emphasisStyle.symbol, makeRange(line: mdEmphasis.startLine, range: mdEmphasis.endSymbol.range)))
                    attributes.append((emphasisStyle.plainText, makeRange(line: mdEmphasis.startLine, range: mdEmphasis.plainText.range)))
                case .link(let mdLink):
                    let linkStyle = themeProvider.linkStyle()
                    attributes.append((linkStyle.text, makeRange(line: mdLink.startLine, range: mdLink.title.range)))
                    let linkRange = makeRange(line: mdLink.startLine, range: mdLink.link.range)
                        // set link styles directly
                    var linkAttributes = linkStyle.link.toAttributes()
                    linkAttributes[.link] = NSURL(string: mdLink.link.0)!
                    additionalStringAttributes.append((linkAttributes, linkRange))
                case .strikeThrough(let mdStrikeThrough):
                    let strikeThroughStyle = themeProvider.strikeThroughStyle()
                    attributes.append((strikeThroughStyle.symbol, makeRange(line: mdStrikeThrough.startLine, range: mdStrikeThrough.startSymbol.range)))
                    attributes.append((strikeThroughStyle.symbol, makeRange(line: mdStrikeThrough.startLine, range: mdStrikeThrough.endSymbol.range)))

                        // set strike throught styles directly
                    var strikeThroughTextAttributes = strikeThroughStyle.plainText.toAttributes()
                    strikeThroughTextAttributes[.strikethroughStyle] = 1
                    additionalStringAttributes.append((strikeThroughTextAttributes, makeRange(line: mdStrikeThrough.startLine, range: mdStrikeThrough.plainText.range)))

                case .image(let mdImage):
                    let imageStyle = themeProvider.imageStyle()
                    let linkRange = makeRange(line: mdImage.startLine, range: mdImage.link.range)
                    attributes.append((imageStyle.title, makeRange(line: mdImage.startLine, range: mdImage.title.range)))

                        // set link styles directly
                    var linkAttributes = imageStyle.link.toAttributes()
                    linkAttributes[.link] = NSURL(string: mdImage.link.0)!
                    additionalStringAttributes.append((linkAttributes, linkRange))
                case .unorderedList(let unorderedList):
                    let unorderedListStyle = themeProvider.unorderedListStyle()
                    unorderedList.items.forEach { item in
                        attributes.append((unorderedListStyle.prefix, makeRange(line: item.startLine, range: item.prefix.range)))
                    }
                case .orderedList(let orderedList):
                    let orderedListStyle = themeProvider.orderedListStyle()
                    orderedList.items.forEach { item in
                        attributes.append((orderedListStyle.index, makeRange(line: item.startLine, range: item.prefix.range)))
                    }
                case .lineBreak(let lineBreak):
                    let lineBreakStyle = themeProvider.lineBreakStyle()
                    attributes.append((lineBreakStyle.plainText, makeRange(line: lineBreak.startLine, range: lineBreak.plainText.range)))
                case .table(let mdTable):
                    let tableStyle = themeProvider.tableStyle()
                    mdTable.heads.forEach { head in
                        attributes.append((tableStyle.head, makeRange(line: mdTable.startLine, range: head.range)))
                    }
                    mdTable.horizontalDividers.forEach { line in
                        line.ranges.forEach { divider in
                            attributes.append((tableStyle.horizontalDivider, makeRange(line: line.startLine, range: divider.range)))
                        }
                    }
                    mdTable.verticalDividers.ranges.forEach { divider in
                        attributes.append((tableStyle.verticalDivider, makeRange(line: mdTable.verticalDividers.startLine, range: divider.range)))
                    }
                case .text:
                    // text use default style
                    break
            }
                // set background color of paragraph individually
            for attribute in additionalStringAttributes {
                textContentStorage.textStorage?.setAttributes(attribute.0, range: attribute.1)
            }
            for attribute in attributes {
                if attribute.0.paragraph.backgroundColor != nil {
                    setParagraphBackgroundColor(in: attribute.1, color: attribute.0.paragraph.backgroundColor!)
                }
                textContentStorage.textStorage?.setAttributes(attribute.0.toAttributes(), range: attribute.1)
            }
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
