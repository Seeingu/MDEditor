//
//  MDTextView+UndoAndRedo.swift
//  
//
//  Created by seeu on 2022/9/18.
//

import Foundation

struct MDUndoElement {
    let source: String

}

extension MDTextView {
    internal func undo() {
        undoManager?.undo()
    }
    internal func redo() {
        undoManager?.redo()
    }
}
