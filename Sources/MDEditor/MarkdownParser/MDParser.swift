//
//  MDParser.swift
//  
//
//  Created by seeu on 2022/9/7.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import Markdown
import MDCommon

// MARK: - Parser
class MDParser {
    private var string: String
    private var lines: [MDSourceLineInfo] = []
    public private(set) var attrs: [MDSourceAttribute] = []

    init(_ string: String, lines: [MDSourceLineInfo]) {
        self.string = string
        self.lines = lines
    }

    func parse() {
        let doc = Document(parsing: string)
        var visitor = MarkdownVisitor(lines: lines)
        visitor.visit(doc)

        attrs = visitor.attrs
    }

}
