//
//  MarkdownMeta.swift
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

/// Line index and offset of markdown source
public struct MDSourceLineInfo {
    public let source: String
        /// starts with 0, different with swift-markdown
    public let line: Int
        /// starts with 0
    public let startLoc: Int
    public let endLoc: Int
    public init(source: String, line: Int, startLoc: Int, endLoc: Int) {
        self.source = source
        self.line = line
        self.startLoc = startLoc
        self.endLoc = endLoc
    }
}

/// Markdown source string attribute
public struct MDSourceAttribute: Identifiable {
    public var id: UUID
    public let plain: String
    public let range: NSRange
    public let sourceRange: SourceRange
    public let mdType: MDType

    public init(plain: String, range: NSRange, sourceRange: SourceRange, mdType: MDType) {
        self.id = UUID()
        self.plain = plain
        self.range = range
        self.sourceRange = sourceRange
        self.mdType = mdType
    }
}
