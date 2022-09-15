//
//  File.swift
//  
//
//  Created by seeu on 2022/9/13.
//

import Foundation
import MDCommon

extension MDTextView {
    internal func updateLineInfo(_ string: String) {
        var loc = 0
        var line = 1
        lines = string.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map { s in
            let r = MDSourceLineInfo(source: String(s), line: line, startLoc: loc, endLoc: loc + s.count)
                // add newline charcater
            loc += s.count + 1
            line += 1
            return r
        }
    }

    func makeRange(line: Int, range: NSRangeOfLine) -> NSRange {
        let startLoc = lines[line].startLoc + range.location
        let endLoc = startLoc + range.length
        return NSRange(location: startLoc, length: endLoc - startLoc)
   }
}
