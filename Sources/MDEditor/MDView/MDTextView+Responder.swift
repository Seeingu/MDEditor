//
//  MDTextView+Responder.swift
//  
//
//  Created by seeu on 2022/9/8.
//

import AppKit

extension MDTextView {
        // MARK: - common
    func replaceCharacters(in range: NSTextRange, with string: String) {
        if !isEditable {
            return
        }
        textContentStorage.textStorage?.replaceCharacters(in: convertRange(from: range), with: string)
        updateMarkdownRender(textContentStorage.textStorage!.string)
        relayout()
    }

    private func moveSelection(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, confined: Bool = false) {
        updateTextSelection(direction: direction, destination: destination, extending: true, confined: confined)
    }
    private func updateTextSelection(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, extending: Bool, confined: Bool = false) {
        textLayoutManager.textSelections = textLayoutManager.textSelections.compactMap { textSelection in
            textLayoutManager.textSelectionNavigation.destinationSelection(
                for: textSelection,
                direction: direction,
                destination: destination,
                extending: extending,
                confined: confined
            )
        }

        updateSelectionHighlights()
        scrollToSelectionCaret()
    }

    private func delete(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, allowsDecomposition: Bool) {
        let textRanges = textLayoutManager.textSelections.flatMap { textSelection -> [NSTextRange] in
            return textLayoutManager.textSelectionNavigation.deletionRanges(
                for: textSelection,
                direction: direction,
                destination: destination,
                allowsDecomposition: allowsDecomposition
            )
        }

        if textRanges.isEmpty {
            return
        }

        textContentStorage.performEditingTransaction {
            for textRange in textRanges {
                replaceCharacters(in: textRange, with: "")
            }
        }
    }

    private func updatePasteboard(with text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([text as NSPasteboardWriting])
    }

    private func moveCaret(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, confined: Bool) {
        updateTextSelection(direction: direction, destination: destination, extending: false, confined: true)
    }
    private func moveCaret(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination) {
        updateTextSelection(direction: direction, destination: destination, extending: false)
    }

    private func scrollToCaret() {
        guard let loc = textLayoutManager.insertionPointLocation else {
            return
        }
        if let selection = textLayoutManager.textSelectionSegmentFrame(at: loc, type: .standard) {
            scrollToVisible(selection)
        }
    }
    private func scrollToSelectionCaret() {
        guard let selection = textLayoutManager.firstSelection, let textRange = selection.textRanges.first else {
            return
        }

        if textRange.isEmpty {
            if let selectionRect = textLayoutManager.textSelectionSegmentFrame(at: textRange.location, type: .selection) {
                scrollToVisible(selectionRect)
            }
        } else {
            switch selection.affinity {
                case .upstream:
                    if let selectionRect = textLayoutManager.textSelectionSegmentFrame(at: textRange.location, type: .selection) {
                        scrollToVisible(selectionRect)
                    }
                case .downstream:
                    if let location = textLayoutManager.location(textRange.endLocation, offsetBy: -1),
                       let selectionRect = textLayoutManager.textSelectionSegmentFrame(at: location, type: .selection) {
                        scrollToVisible(selectionRect)
                    }
                @unknown default:
                    break
            }
        }
    }

    private func performMouseDownActions() {
        let attr = mdAttrs.first { attr in
            let attrRange = convertRange(from: attr.range)
            if let r = attrRange, r.contains(textLayoutManager.textSelections.first!.textRanges.first!.location) {
                return true
            }
            return false
        }
            // TODO: support more schemes
        if let a = attr, a.plain.hasPrefix("http"), let url = URL(string: a.plain) {
            NSWorkspace.shared.open(url)
        }
    }

        // MARK: - mouse event
    override func mouseDown(with event: NSEvent) {
        switch event.clickCount {
            case 2:
                selectWord(self)
            case 3:
                selectLine(self)
            default:
                var point = convert(event.locationInWindow, from: nil)
                point.x -= padding
                let nav = textLayoutManager.textSelectionNavigation

                textLayoutManager.textSelections = nav.textSelections(
                    interactingAt: point,
                    inContainerAt: textLayoutManager.documentRange.location,
                    anchors: [],
                    modifiers: [],
                    selecting: true,
                    bounds: .zero)

                    // open link
                if event.modifierFlags.contains(.command) {
                    performMouseDownActions()
                }

        }

        relayout()
    }

    override func mouseDragged(with event: NSEvent) {
        var point = convert(event.locationInWindow, from: nil)
        point.x -= padding
        let nav = textLayoutManager.textSelectionNavigation

        textLayoutManager.textSelections = nav.textSelections(
            interactingAt: point,
            inContainerAt: textLayoutManager.documentRange.location,
            anchors: textLayoutManager.textSelections,
            modifiers: .extend,
            selecting: true,
            bounds: .zero)

        relayout()
    }

    override func mouseUp(with event: NSEvent) {
    }

        // MARK: - keyboard event
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

        // MARK: - insert

    override func insertTab(_ sender: Any?) {
        insertText("\t")
    }

    override func insertLineBreak(_ sender: Any?) {
        insertNewline(self)
    }

    override func insertNewline(_ sender: Any?) {
        insertText("\n")

        scrollToCaret()
    }

        // MARK: - copy & paste
    func copy(_ sender: Any?) {
        if let textSelectionsString = textLayoutManager.textSelectionsString(), !textSelectionsString.isEmpty {
            updatePasteboard(with: textSelectionsString)
        }
    }

    func paste(_ sender: Any?) {
        guard let string = NSPasteboard.general.string(forType: .string),
              let firstTextSelectionRange = textLayoutManager.textSelections.first?.textRanges.first
        else {
            return
        }

        replaceCharacters(in: firstTextSelectionRange, with: string)
    }

    func cut(_ sender: Any?) {
        copy(sender)
        delete(sender)
    }

    func delete(_ sender: Any?) {
        for textRange in textLayoutManager.textSelections.flatMap(\.textRanges) {
                // "replaceContents" doesn't work with NSTextContentStorage at all
                // textLayoutManager.replaceContents(in: textRange, with: NSAttributedString())
                //            textLayoutManager.replaceContents(in: textRange, with: NSAttributedString(string: ""))
            insertText("", replacementRange: convertRange(from: textRange))
        }
    }

        // MARK: - Select

    /// Key: Command + a
    override func selectAll(_ sender: Any?) {
        textLayoutManager.textSelections = [
            NSTextSelection(range: textLayoutManager.documentRange, affinity: .downstream, granularity: .paragraph)
        ]

        updateSelectionHighlights()
    }

    override func selectWord(_ sender: Any?) {
        guard let selection = textLayoutManager.firstSelection else {
            return
        }
        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(for: .word, enclosing: selection)
        ]
    }

    override func selectLine(_ sender: Any?) {
        guard let selection = textLayoutManager.firstSelection else {
            return
        }
        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(for: .line, enclosing: selection)
        ]
    }

    override func selectParagraph(_ sender: Any?) {
        guard let selection = textLayoutManager.firstSelection else {
            return
        }
        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(for: .paragraph, enclosing: selection)
        ]
    }

        /// Key:  Shift + left arrow
    override func moveLeftAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .left, destination: .character)
    }

        /// Key: Shift + right arrow
    override func moveRightAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .right, destination: .character)
    }

        /// Key: Shift + up arrow
    override func moveUpAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .up, destination: .character)
    }

        /// Key: Shift + down arrow
    override func moveDownAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .down, destination: .character)
    }

        /// Key: Shift + Option + left arrow
    override func moveWordLeftAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .left, destination: .word)
    }

        /// Key: Shift + Option + right arrow
    override func moveWordRightAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .right, destination: .word)
    }

        /// Key:
    override func moveWordForwardAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .forward, destination: .word)
    }

    override func moveWordBackwardAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .backward, destination: .word)
    }

        /// Key: Command + Shift + arrow left
    override func moveToBeginningOfLineAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .left, destination: .line, confined: true)
    }

        /// Key: Command + Shift + arrow right
    override func moveToEndOfLineAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .right, destination: .line, confined: true)
    }

        /// Key: Control + Shift + a
    override func moveToBeginningOfParagraphAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .left, destination: .paragraph)
    }

        /// Key: Control + Shift + e
    override func moveToEndOfParagraphAndModifySelection(_ sender: Any?) {
        moveSelection(direction: .right, destination: .paragraph)
    }

        // MARK: - Move

        /// Key: arrow up
    override func moveUp(_ sender: Any?) {
        moveCaret(direction: .up, destination: .character)
    }

        /// Key: arrow left
    override func moveLeft(_ sender: Any?) {
        moveCaret(direction: .left, destination: .character)
    }

        /// Key: arrow right
    override func moveRight(_ sender: Any?) {
        moveCaret(direction: .right, destination: .character)
    }

        /// Key: arrow down
    override func moveDown(_ sender: Any?) {
        moveCaret(direction: .down, destination: .character)
    }

        /// Key: Control + f
    override func moveForward(_ sender: Any?) {
        moveCaret(direction: .forward, destination: .character)
    }

        /// Key: Control + b
    override func moveBackward(_ sender: Any?) {
        moveCaret(direction: .backward, destination: .character)
    }

        /// Key: Option + arrow left
    override func moveWordLeft(_ sender: Any?) {
        moveCaret(direction: .left, destination: .word)
    }

        /// Key: Option + arrow right
    override func moveWordRight(_ sender: Any?) {
        moveCaret(direction: .right, destination: .word)
    }

        /// Key: Control + Option + f
    override func moveWordForward(_ sender: Any?) {
        moveCaret(direction: .forward, destination: .word)
    }

        /// Key: Control + Option + b
    override func moveWordBackward(_ sender: Any?) {
        moveCaret(direction: .backward, destination: .word)
    }

        /// Key: Command + arrow left
    override func moveToBeginningOfLine(_ sender: Any?) {
        moveCaret(direction: .left, destination: .line, confined: true)
    }

        /// Key: Command + arrow right
    override func moveToEndOfLine(_ sender: Any?) {
        moveCaret(direction: .right, destination: .line, confined: true)
    }

        /// Key: Command + arrow left
    override func moveToLeftEndOfLine(_ sender: Any?) {
        moveCaret(direction: .left, destination: .line)
    }

        /// Key: Control + a
    override func moveToBeginningOfParagraph(_ sender: Any?) {
        moveCaret(direction: .backward, destination: .paragraph, confined: true)
    }

        /// Key: Control + e
    override func moveToEndOfParagraph(_ sender: Any?) {
        moveCaret(direction: .forward, destination: .paragraph, confined: true)
    }

        // MARK: - delete

        /// Key: Fn-delete
    override func deleteForward(_ sender: Any?) {
        delete(direction: .forward, destination: .character, allowsDecomposition: false)
    }

        /// Key: delete
    override func deleteBackward(_ sender: Any?) {
        delete(direction: .backward, destination: .character, allowsDecomposition: false)
    }

}
