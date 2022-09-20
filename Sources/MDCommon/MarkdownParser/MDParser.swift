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

// MARK: - Parser
public class MDParser {
    private var string: String
    private var lines: [MDSourceLineInfo] = []
    public private(set) var attrs: [MDSourceAttribute] = []

    public init(_ string: String, lines: [MDSourceLineInfo]? = nil) {
        self.string = string
        self.lines = lines ?? getLines(string)
    }

    public func parse() {
        let doc = Document(parsing: string)
        var visitor = MarkdownVisitor(lines: lines)
        visitor.visit(doc)

        attrs = visitor.attrs
    }

    public func format() -> String {
        let doc = Document(parsing: string)
        // use swift-markdown's default formatter
        return doc.format()
    }

    // MARK: - private
    private func getLines(_ string: String) -> [MDSourceLineInfo] {
        var loc = 0
        var line = 1
        return string.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map { s in
            let r = MDSourceLineInfo(source: String(s), line: line, startLoc: loc, endLoc: loc + s.count)
                // add newline charcater
            loc += s.count + 1
            line += 1
            return r
        }
    }

}
