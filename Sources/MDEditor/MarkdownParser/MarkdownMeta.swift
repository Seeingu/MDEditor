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
import MDCommon

internal struct MDSourceLineInfo {
    let source: String
        /// starts with 0, different with swift-markdown
    let line: Int
        /// starts with 0
    let startLoc: Int
    let endLoc: Int
}

internal struct MDSourceAttribute {
    let plain: String
    let range: NSRange
    let sourceRange: SourceRange
    let mdType: MDType

    init(plain: String, range: NSRange, sourceRange: SourceRange, mdType: MDType) {
        self.plain = plain
        self.range = range
        self.sourceRange = sourceRange
        self.mdType = mdType
    }
}
