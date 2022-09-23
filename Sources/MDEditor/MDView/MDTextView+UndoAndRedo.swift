//
//  MDTextView+UndoAndRedo.swift
//  
//
//  Created by seeu on 2022/9/18.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension MDTextView {
    internal func undo() {
        guard let undoSource = stateModel.undoStackManager.undo() else {
            return
        }
        stateModel.undoStackManager.registerRedo(
            source: mdString,
            caretLocation: caretLocation,
            editRange: undoSource.editRange)

        self.setString(undoSource.source)
        textViewDelegate?.onTextChange(undoSource.source)
        changeCaretPosition(in: NSTextRange(location: undoSource.caretLocation))

        // TODO: works with undoManager

    }
    internal func redo() {
        guard let undoSource = stateModel.undoStackManager.redo() else {
            return
        }

        stateModel.undoStackManager.registerUndo(
            source: mdString,
            caretLocation: caretLocation,
            editRange: undoSource.editRange)

        self.setString(undoSource.source)
        textViewDelegate?.onTextChange(undoSource.source)
        changeCaretPosition(in: NSTextRange(location: undoSource.caretLocation))
    }
}
