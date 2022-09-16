//
//  MarkdownVisitor.swift
//  
//
//  Created by seeu on 2022/9/15.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import Markdown
import MDCommon

fileprivate extension MDRangeIterator {
    convenience init(at sourceRange: SourceRange) {
        self.init(start: sourceRange.lowerBound.column - 1)
    }
}

private func makeRange(lines: [MDSourceLineInfo], from range: SourceRange) -> NSRange {
    let startLoc = lines[range.startLine].startLoc + range.lowerBound.column - 1
    let endLoc = lines[range.endLine].startLoc + range.upperBound.column - 1
    return NSRange(location: startLoc, length: endLoc - startLoc)
}

internal struct MarkdownVisitor: MarkupWalker {
    var attrs: [MDSourceAttribute] = []
    let lines: [MDSourceLineInfo]

    init(lines: [MDSourceLineInfo]) {
        self.lines = lines
    }

    func range(from sourceRange: SourceRange) -> NSRange {
        makeRange(lines: self.lines, from: sourceRange)
    }

        // MARK: - block
    mutating func visitHeading(_ heading: Heading) {
        guard let sourceRange = heading.range else {
            return
        }

        let rangeIterator = MDRangeIterator(at: sourceRange)
        let levelRange = rangeIterator.next(heading.level)
        rangeIterator.next(" ")
        let mdHeading = MDHeading(startLine: sourceRange.startLine, level: (heading.level, levelRange), plainText: rangeIterator.next(heading.plainText))
        attrs.append(MDSourceAttribute(plain: heading.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .heading(mdHeading)))
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        guard let sourceRange = blockQuote.range else {
            return
        }

        var blocks: [MDBlockQuoteBlock] = []
        for child in blockQuote.blockChildren {
            guard let childRange = child.range else {
                continue
            }
            let textStartColumn = childRange.lowerBound.column - 1
            let rangeIterator = MDRangeIterator(start: 0)

                // TODO: handle nested blocks
            let symbol = rangeIterator.next(">")

                // skip other characters before plainText
            rangeIterator.next(textStartColumn - 1)

            var plainText = child.format()
            let index = plainText.index(plainText.startIndex, offsetBy: textStartColumn - 1)
            plainText = String(plainText[index...])

            blocks.append((symbol, rangeIterator.next(plainText)))
        }
        let mdBlockQuote = MDBlockQuote(startLine: sourceRange.startLine, endLine: sourceRange.endLine, blocks: blocks)
        attrs.append(MDSourceAttribute(plain: blockQuote.format(),
                                       range: range(from: sourceRange), sourceRange: sourceRange, mdType: .blockQuote(mdBlockQuote)))
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        guard let sourceRange = codeBlock.range else {
            return
        }
        let startLine = sourceRange.startLine

        let symbol = "```"
        let rangeIterator = MDRangeIterator(at: sourceRange)
        let startSymbol = rangeIterator.next(symbol)
        var language: MDStringLineRange?
        if codeBlock.language != nil {
            language = rangeIterator.next(codeBlock.language!)
        }
        let code = rangeIterator.next(codeBlock.code)
        rangeIterator.next("\n")
        let endSymbol = rangeIterator.next(symbol)

        let mdCodeBlock = MDCodeBlock(startLine: startLine, startSymbol: startSymbol, language: language, plainText: code, endSymbol: endSymbol)
        self.attrs.append(MDSourceAttribute(plain: codeBlock.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .codeBlock(mdCodeBlock)))
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) {
            // TODO
    }

    func visitSoftBreak(_ softBreak: SoftBreak) {
            // TODO
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) {
        guard let sourceRange = thematicBreak.range else {
            return
        }
        let plainText = thematicBreak.format()
        let mdLineBreak = MDLineBreak(startLine: sourceRange.startLine, plainText: MDRangeIterator(at: sourceRange).next(plainText))
        self.attrs.append(MDSourceAttribute(plain: thematicBreak.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .lineBreak(mdLineBreak)))
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) {
        guard let sourceRange = strikethrough.range else {
            return
        }
        let rangeIterator = MDRangeIterator(at: sourceRange)
        let symbol = "~~"

            // the plaintext strikethrough given has prefix and postfix `~` symbol
        var plainText = strikethrough.plainText
        let plainTextStartIndex = plainText.index(after: plainText.startIndex)
        let plainTextEndIndex = plainText.index(before: plainText.endIndex)
        plainText = String(plainText[plainTextStartIndex..<plainTextEndIndex])

        let mdStrikeThrough = MDStrikeThrough(startLine: sourceRange.startLine, startSymbol: rangeIterator.next(symbol), plainText: rangeIterator.next(plainText), endSymbol: rangeIterator.next(symbol))
        self.attrs.append(MDSourceAttribute(plain: strikethrough.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .strikeThrough(mdStrikeThrough)))
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) {
        guard let sourceRange = orderedList.range else {
            return
        }
        var orderedItems: [MDOrderedItem] = []

        var inlineAttrs: [MDSourceAttribute] = []

        orderedList.children.forEach { child in
            guard let childRange = child.range, let listItem = child as? ListItem else {
                return
            }

            let rangeIterator = MDRangeIterator(at: listItem.range!)
            let index = child.indexInParent
            let prefixRange = rangeIterator.next("\(index).")
            rangeIterator.next(" ")
            var visitor = MarkdownVisitor(lines: self.lines)
            listItem.children.forEach { child in visitor.visit(child)}

            inlineAttrs.append(contentsOf: visitor.attrs)

            orderedItems.append(MDOrderedItem(startLine: childRange.startLine, index: index, prefix: prefixRange, plainText: rangeIterator.next(listItem.format())))
        }

        let mdOrderedList = MDOrderedList(startLine: sourceRange.startLine, items: orderedItems)

        self.attrs.append(MDSourceAttribute(
            plain: orderedList.format(),
            range: range(from: sourceRange),
            sourceRange: sourceRange,
            mdType: .orderedList(mdOrderedList)))
            // place inline attributes after block attributes to replace block style
        attrs.append(contentsOf: inlineAttrs)
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) {
        guard let sourceRange = unorderedList.range else {
            return
        }
        let startLine = sourceRange.startLine
        var unorderedItems: [MDUnorderedItem] = []
        var index = 0
        var inlineAttrs: [MDSourceAttribute] = []
        unorderedList.children.forEach { child in
            guard let listItem = child as? ListItem else {
                return
            }

            let rangeIterator = MDRangeIterator(at: listItem.range!)
            let prefixRange = rangeIterator.next("-")
            var checkbox: (MDCheckbox, NSRangeOfLine)?
            rangeIterator.next(" ")
            if listItem.checkbox != nil {
                    // skip space
                switch listItem.checkbox! {
                    case .checked:
                        checkbox = (MDCheckbox(checked: true), rangeIterator.next("[x]".count))
                    case .unchecked:
                        checkbox = (MDCheckbox(checked: false), rangeIterator.next("[ ]".count))
                }
                rangeIterator.next(" ")
            }
            var visitor = MarkdownVisitor(lines: self.lines)
            listItem.children.forEach { child in visitor.visit(child)}

            inlineAttrs.append(contentsOf: visitor.attrs)

            unorderedItems.append(MDUnorderedItem(startLine: startLine + index, prefix: prefixRange, indexInParent: index, checkbox: checkbox, plainText: rangeIterator.next(listItem.format())))
            index += 1
        }
        let mdUnorderedList = MDUnorderedList(startLine: sourceRange.startLine, items: unorderedItems)
        attrs.append(MDSourceAttribute(plain: unorderedList.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .unorderedList(mdUnorderedList)))
            // place inline attributes after block attributes to replace block style
        attrs.append(contentsOf: inlineAttrs)
    }

    mutating func visitTable(_ table: Table) {
        guard let sourceRange = table.range else {
            return
        }

        var inlineAttrs: [MDSourceAttribute] = []
        let bar = "|"

        var line = sourceRange.startLine
        var horizontalDividers: [MDTableDivider] = []
        var heads: [MDStringLineRange] = []
        var items: [MDTableItem] = []
        var verticalDividerRanges: [MDStringLineRange] = []

        var columnWidths: [Int] = []
        // first row: header
        if let headRange = table.head.range {
            var horizontalDividerRanges: [MDStringLineRange] = []
            let rangeIterator = MDRangeIterator(at: headRange)
            horizontalDividerRanges.append((rangeIterator.next(bar)))
            columnWidths.append(bar.count)
            table.head.cells.forEach { cell in
                guard let cellRange = cell.range else { return }
                let columnWidth = cellRange.upperBound.column - cellRange.lowerBound.column
                columnWidths.append(columnWidth)
                    // plainText is the text part of head, range contains left and right string paddings
                heads.append((cell.plainText, rangeIterator.next(columnWidth)))
                horizontalDividerRanges.append(rangeIterator.next(bar))
                columnWidths.append(bar.count)
            }
            horizontalDividers.append(MDTableDivider(startLine: line, ranges: horizontalDividerRanges))
        }

        // second row: divider
        line += 1
        let dividerRangeIterator = MDRangeIterator(start: 0)
        var isBar = true
        var dividerBarHorizontalRanges: [MDStringLineRange] = []
        columnWidths.forEach { width in
            if isBar {
                dividerBarHorizontalRanges.append(dividerRangeIterator.next(bar))
            } else {
                verticalDividerRanges.append(("-", dividerRangeIterator.next(width)))
            }
            isBar = !isBar
        }
        let verticalDividers = MDTableDivider(startLine: line, ranges: verticalDividerRanges)
        horizontalDividers.append(MDTableDivider(startLine: line, ranges: dividerBarHorizontalRanges))

        // body
        line += 1
        table.body.rows.forEach { row in
            guard let rowRange = row.range else { return }
            var horizontalDividerRanges: [MDStringLineRange] = []
            let rangeIterator = MDRangeIterator(at: rowRange)
            horizontalDividerRanges.append((rangeIterator.next(bar)))

            var lineIndex = 0
            var columnIndex = 0
            row.cells.forEach { cell in
                guard let cellRange = cell.range else { return }
                let columnWidth = cellRange.upperBound.column - cellRange.lowerBound.column

                    // plainText is the text part of head, range contains left and right string paddings
                items.append(MDTableItem(
                    startLine: cellRange.startLine,
                    lineIndex: lineIndex,
                    columnIndex: columnIndex,
                    plainText: (cell.plainText, rangeIterator.next(columnWidth))))
                horizontalDividerRanges.append(rangeIterator.next(bar))

                // visit inline attrs
                var visitor = MarkdownVisitor(lines: self.lines)
                visitor.visit(cell)
                inlineAttrs.append(contentsOf: visitor.attrs)

                // update line info
                if columnIndex + 1 == table.maxColumnCount {
                    lineIndex += 1
                    columnIndex = 0
                } else {
                    columnIndex += 1
                }
            }
            horizontalDividers.append(MDTableDivider(startLine: line, ranges: horizontalDividerRanges))
            line += 1
        }

        let mdTable = MDTable(startLine: sourceRange.startLine, heads: heads, verticalDividers: verticalDividers, horizontalDividers: horizontalDividers, items: items)

        attrs.append(MDSourceAttribute(plain: table.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .table(mdTable)))
                    // place inline attributes after block attributes to replace block style
        attrs.append(contentsOf: inlineAttrs)

    }

        // MARK: - inline

    mutating func visitText(_ text: Text) {
        guard let sourceRange = text.range else {
            return
        }
        let mdText = MDText(startLine: sourceRange.startLine, text: MDRangeIterator(at: sourceRange).next(text.plainText))
        attrs.append(MDSourceAttribute(plain: text.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .text(mdText)))
    }

    mutating func visitStrong(_ strong: Strong) {
        guard let sourceRange = strong.range else {
            return
        }
        let rangeIterator = MDRangeIterator(at: sourceRange)

        let mdEmphasis = MDEmphasis(startLine: sourceRange.startLine, startSymbol: rangeIterator.next("**"), plainText: rangeIterator.next(strong.plainText), endSymbol: rangeIterator.next("**"), type: .strong)
        attrs.append(MDSourceAttribute(plain: strong.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .emphasis(mdEmphasis)))
    }

        /// italic and bold&italic type
    mutating func visitEmphasis(_ emphasis: Emphasis) {
        guard let sourceRange = emphasis.range else {
            return
        }

        let originalText = emphasis.format()
        var symbol = "*"
        var emphasisType = EmphasisType.italic

            // bold and italic
        if originalText.hasPrefix("***") || originalText.hasPrefix("___") {
            symbol = "***"
            emphasisType = .strongAndItalic
        }
        let rangeIterator = MDRangeIterator(at: sourceRange)

        let mdEmphasis = MDEmphasis(startLine: sourceRange.startLine,
                                    startSymbol: rangeIterator.next(symbol),
                                    plainText: rangeIterator.next(emphasis.plainText),
                                    endSymbol: rangeIterator.next(symbol),
                                    type: emphasisType)
        attrs.append(MDSourceAttribute(plain: emphasis.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .emphasis(mdEmphasis)))
    }

        /// Syntax: [plainText](destination)
    mutating func visitLink(_ link: Link) {
        guard let destination = link.destination, let sourceRange = link.range else {
            return
        }

        let startLine = sourceRange.startLine

        let rangeIterator = MDRangeIterator(at: sourceRange)

        let mdLink = MDLink(startLine: startLine,
                            titleLeftSymbol: rangeIterator.next("["),
                            title: rangeIterator.next(link.plainText),
                            titleRightSymbol: rangeIterator.next("]"),
                            linkLeftSymbol: rangeIterator.next("("),
                            link: rangeIterator.next(destination),
                            linkRightSymbol: rangeIterator.next(")"))

        attrs.append(MDSourceAttribute(plain: link.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .link(mdLink)))
    }

        /// Syntax: ![plainText](sourceLink)
    mutating func visitImage(_ image: Image) {
        guard let _ = image.source, let sourceRange = image.range else {
            return
        }

        let startLine = sourceRange.startLine

        let rangeIterator = MDRangeIterator(at: sourceRange)
        let mdImage = MDImage(startLine: startLine, prefixSymbol: rangeIterator.next("!"), titleLeftSymbol: rangeIterator.next("["), title: rangeIterator.next(image.plainText), titleRightSymbol: rangeIterator.next("]"), linkLeftSymbol: rangeIterator.next("("), link: rangeIterator.next(image.source ?? ""), linkRightSymbol: rangeIterator.next(")"))

        attrs.append(MDSourceAttribute(plain: image.format(),
                                       range: range(from: sourceRange), sourceRange: sourceRange, mdType: .image(mdImage)))
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        guard let sourceRange = inlineCode.range else {
            return
        }
        let rangeIterator = MDRangeIterator(at: sourceRange)
        let mdInlineCode = MDInlineCode(startLine: sourceRange.startLine, startSymbol: rangeIterator.next("`"), plainText: rangeIterator.next(inlineCode.code), endSymbol: rangeIterator.next("`"))
        self.attrs.append(MDSourceAttribute(plain: inlineCode.format(), range: range(from: sourceRange), sourceRange: sourceRange, mdType: .codeInline(mdInlineCode)))
    }

}
