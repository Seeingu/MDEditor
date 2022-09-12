//
//  MDParser.swift
//  
//
//  Created by seeu on 2022/9/7.
//

import AppKit
import Markdown
import MDCommon

struct LineInfo {
    let source: String
    let line: Int
    let startLoc: Int
    let endLoc: Int
}

struct MDAttr {
    let plain: String
    let attrs: [NSAttributedString.Key: Any]
    let range: NSRange
    let sourceRange: SourceRange
    let mdType: MDType

    init(plain: String, attrs: [NSAttributedString.Key: Any], range: NSRange, sourceRange: SourceRange, mdType: MDType = .text) {
        self.plain = plain
        self.attrs = attrs
        self.range = range
        self.sourceRange = sourceRange
        self.mdType = mdType
    }
}

private func makeRange(lines: [LineInfo], lowerLine: Int, lowerColumn: Int, upperLine: Int, upperColumn: Int) -> NSRange {
    let startLoc = lines[lowerLine - 1].startLoc + lowerColumn - 1
    let endLoc = lines[upperLine - 1].startLoc + upperColumn - 1
    return NSRange(location: startLoc, length: endLoc - startLoc)
}
private func makeRange(lines: [LineInfo], from range: SourceRange) -> NSRange {
    let startLoc = lines[range.lowerBound.line - 1].startLoc + range.lowerBound.column - 1
    let endLoc = lines[range.upperBound.line - 1].startLoc + range.upperBound.column - 1
    return NSRange(location: startLoc, length: endLoc - startLoc)
}

private struct Visitor: MarkupWalker {
    var attrs: [MDAttr] = []
    let lines: [LineInfo]

    init(lines: [LineInfo]) {
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
        attrs.append(MDAttr(plain: heading.plainText, attrs: [:], range: range(from: sourceRange), sourceRange: sourceRange, mdType: .heading(heading.level)))
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        guard let sourceRange = blockQuote.range else {
            return
        }

        attrs.append(MDAttr(plain: "blockquote", attrs: [:],
                            range: range(from: sourceRange), sourceRange: sourceRange, mdType: .blockQuote))
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        guard let sourceRange = codeBlock.range else {
            return
        }
        self.attrs.append(MDAttr(plain: codeBlock.code, attrs: [:], range: range(from: sourceRange), sourceRange: sourceRange, mdType: .codeBlock))
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
        let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraph.lineHeightMultiple = 0.8
        self.attrs.append(MDAttr(plain: "", attrs: [
            .font: NSFont.systemFont(ofSize: 20, weight: .light),
            .paragraphStyle: paragraph
        ], range: range(from: sourceRange), sourceRange: sourceRange))
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) {
        guard let sourceRange = strikethrough.range else {
            return
        }
        self.attrs.append(MDAttr(plain: strikethrough.plainText, attrs: [
            .strikethroughStyle: 1
        ], range: range(from: sourceRange), sourceRange: sourceRange))
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) {
        orderedList.listItems.forEach { item in
            self.attrs.append(MDAttr(plain: String(item.indexInParent), attrs: [
                .font: NSFont.monospacedSystemFont(ofSize: 20, weight: .thin)
            ], range: range(from: item.range!), sourceRange: item.range!))
        }
    }

        /// visit unordered list's item
    mutating func visitListItem(_ listItem: ListItem) {
        attrs.append(MDAttr(plain: listItem.format(), attrs: [
                .font: NSFont.monospacedSystemFont(ofSize: 20, weight: .thin)
        ], range: range(from: listItem.range!), sourceRange: listItem.range!))
    }

    func visitTable(_ table: Table) {
        // TODO
    }

    // MARK: - inline

    mutating func visitText(_ text: Text) {
        guard let sourceRange = text.range else {
            return
        }
        let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraph.lineHeightMultiple = 1.1
        paragraph.defaultTabInterval = 28 // default
        attrs.append(MDAttr(plain: text.plainText, attrs: [:
        ], range: range(from: sourceRange), sourceRange: sourceRange))

    }

    mutating func visitStrong(_ strong: Strong) {
        guard let sourceRange = strong.range else {
            return
        }
        attrs.append(MDAttr(plain: strong.plainText, attrs: [
            .font: NSFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        ], range: range(from: sourceRange), sourceRange: sourceRange))
    }

    /// italic
    mutating func visitEmphasis(_ emphasis: Emphasis) {
        // TODO: should handle bold and italic
        guard let sourceRange = emphasis.range else {
            return
        }
        attrs.append(MDAttr(plain: emphasis.plainText, attrs: [
            .font: NSFont.monospacedSystemFont(ofSize: 20, weight: .regular).italics()
        ], range: range(from: sourceRange), sourceRange: sourceRange))
    }

    /// Syntax: [plainText](destination)
    mutating func visitLink(_ link: Link) {
        guard let destination = link.destination, let sourceRange = link.range else {
            return
        }

        let urlRangeLowerColumn = sourceRange.lowerBound.column + link.plainText.count + 3
        let urlRangeUpperColumn = sourceRange.upperBound.column - 1
        let lowerLine = sourceRange.lowerBound.line
        let upperLine = sourceRange.upperBound.line

        attrs.append(MDAttr(plain: destination, attrs: [
            .link: NSURL(string: destination)!
        ], range: makeRange(lines: self.lines, lowerLine: lowerLine, lowerColumn: urlRangeLowerColumn, upperLine: upperLine, upperColumn: urlRangeUpperColumn), sourceRange: link.range!))
    }

    /// Syntax: ![plainText](sourceLink)
    mutating func visitImage(_ image: Image) {
        guard let source = image.source, let sourceRange = image.range else {
            return
        }

        let imageSourceRangeLowerColumn = sourceRange.lowerBound.column + image.plainText.count + 4
        let imageSourceRangeUpperColumn = sourceRange.upperBound.column - 1

        let lowerLine = sourceRange.lowerBound.line
        let upperLine = sourceRange.upperBound.line

        attrs.append(MDAttr(plain: source, attrs: [
            .link: NSURL(string: source)!
        ], range: makeRange(lines: self.lines, lowerLine: lowerLine, lowerColumn: imageSourceRangeLowerColumn, upperLine: upperLine, upperColumn: imageSourceRangeUpperColumn), sourceRange: image.range!))
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        self.attrs.append(MDAttr(plain: inlineCode.plainText, attrs: [:], range: range(from: inlineCode.range!), sourceRange: inlineCode.range!, mdType: .codeInline))
    }

}

// MARK: - Parser
class MDParser {
    private var string: String
    public var lines: [LineInfo] = []
    public private(set) var attrs: [MDAttr] = []

    init(_ string: String) {
        var loc = 0
        var line = 1
        lines = string.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map { s in
            let r = LineInfo(source: String(s), line: line, startLoc: loc, endLoc: loc + s.count)
            // add newline charcater
            loc += s.count + 1
            line += 1
            return r
        }
        self.string = string
    }

    func parse() {
        let doc = Document(parsing: string)
        var visitor = Visitor(lines: lines)
        visitor.visit(doc)

        attrs = visitor.attrs
    }

}
