//
//  UndoAndRedo.swift
//  
//
//  Created by seeu on 2022/9/23.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct MDUndoSource {
    var source: String
    var caretLocation: NSTextLocation
    var editRange: NSTextRange
}

extension Array where Element == MDUndoSource? {
    mutating func register(at index: inout Int, undoSource: MDUndoSource) {
        index += 1
        self[index] = undoSource
    }
    mutating func perform(index: inout Int) -> MDUndoSource? {
        if 0..<self.count ~= index {
            let undoSource = self[index]
            index -= 1
            return undoSource
        }
        return nil
    }
}

class UndoStackManager {
        // MARK: - undo
    private var sourceStack = [MDUndoSource?](repeating: nil, count: 100)
    private var index: Int = -1

    func undo() -> MDUndoSource? {
        sourceStack.perform(index: &index)
    }

    func registerUndo(source: String, caretLocation: NSTextLocation, editRange: NSTextRange) {
        sourceStack.register(at: &index, undoSource: MDUndoSource(source: source, caretLocation: caretLocation, editRange: editRange))
    }

        // MARK: - redo
    private var redoStack = [MDUndoSource?](repeating: nil, count: 100)
    private var redoIndex: Int = -1

    func registerRedo(source: String, caretLocation: NSTextLocation, editRange: NSTextRange) {
        redoStack.register(at: &redoIndex, undoSource: MDUndoSource(source: source, caretLocation: caretLocation, editRange: editRange))
    }

    func redo() -> MDUndoSource? {
        redoStack.perform(index: &redoIndex)
    }
}
