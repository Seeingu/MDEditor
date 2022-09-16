//
//  Markdown+.swift
//  
//
//  Created by seeu on 2022/9/15.
//

import Foundation
import Markdown

extension SourceRange {
    var startLine: Int {
        self.lowerBound.line - 1
    }
    var endLine: Int {
        self.upperBound.line - 1
    }
}
