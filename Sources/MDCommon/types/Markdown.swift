//
//  Markdown.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import Foundation

/// Markdown type enumeration
public enum MDType {
    case paragraph
    case heading(Int)
    case codeBlock
    case codeInline
    case blockQuote
    case text
}
