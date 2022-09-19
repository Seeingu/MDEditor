//
//  MDTextView+Responder.swift
//  
//
//  Created by seeu on 2022/9/8.
//

import MDCommon

extension MDTextView {
        // MARK: - common

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
        scrollToSelection()
    }

    private func moveCaret(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination, confined: Bool) {
        updateTextSelection(direction: direction, destination: destination, extending: false, confined: true)
    }
    private func moveCaret(direction: NSTextSelectionNavigation.Direction, destination: NSTextSelectionNavigation.Destination) {
        updateTextSelection(direction: direction, destination: destination, extending: false)
    }

    internal func scrollToCaret() {
        guard let loc = textLayoutManager.insertionPointLocation else {
            return
        }
        if let selection = textLayoutManager.textSelectionSegmentFrame(at: loc, type: .standard) {
            scrollToVisible(selection)
        }
    }

    internal func changeCaretPosition(at point: CGPoint) {
        var point = point
        point.x -= padding
        let nav = textLayoutManager.textSelectionNavigation

        textLayoutManager.textSelections = nav.textSelections(
            interactingAt: point,
            inContainerAt: textLayoutManager.documentRange.location,
            anchors: [],
            modifiers: [],
            selecting: true,
            bounds: .zero)

    }
    internal func changeCaretPosition(in range: NSTextRange) {
        textLayoutManager.textSelections = [
            NSTextSelection(range: range, affinity: .downstream, granularity: .character)
        ]
    }

    internal func scrollToSelection() {
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

    func selectWord() {
        guard let selection = textLayoutManager.firstSelection else {
            return
        }
        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(for: .word, enclosing: selection)
        ]
    }

    func selectLine() {
        guard let selection = textLayoutManager.firstSelection else {
            return
        }
        textLayoutManager.textSelections = [
            textLayoutManager.textSelectionNavigation.textSelection(for: .line, enclosing: selection)
        ]
    }

    func copyAction() {
        if let textSelectionsString = textLayoutManager.textSelectionsString(), !textSelectionsString.isEmpty {
            MDPasteboard.writeToPasteboard(with: textSelectionsString)
        }
    }

    func pasteAction() {
        guard let string = MDPasteboard.readPasteboard(),
              let firstTextSelectionRange = textLayoutManager.textSelections.first?.textRanges.first
        else {
            return
        }

        replaceCharacters(in: firstTextSelectionRange, with: string)
    }

    func cutAction() {
        copyAction()
        deleteAction()
    }

    func deleteAction() {
        for textRange in textLayoutManager.textSelections.flatMap(\.textRanges) {
            insertString("", replacementRange: convertRange(from: textRange))
        }
    }
}

#if os(macOS)
import AppKit

extension MDTextView {
        // MARK: - mac common

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
                let point = convert(event.locationInWindow, from: nil)
                changeCaretPosition(at: point)

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
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers {
                case "c":
                    copyAction()
                    return
                case "v":
                    pasteAction()
                    return
                case "x":
                    cutAction()
                    return
                case "f":
                    showFinderBar()
                    return
                default:
                    break
            }
        }
        interpretKeyEvents([event])
    }
        // MARK: - insert

    override func insertTab(_ sender: Any?) {
        insertString("\t")
    }

    override func insertLineBreak(_ sender: Any?) {
        insertNewline(self)
    }

    override func insertNewline(_ sender: Any?) {
        insertString("\n")
    }

        // MARK: - copy & paste

    override func yank(_ sender: Any?) {
        cutAction()
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
        selectWord()
    }

    override func selectLine(_ sender: Any?) {
        selectLine()
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
#else
// MARK: iOS gesture
import UIKit

enum EditIdentifier {
    case longPress
    case textEdit
}

extension MDTextView: UIEditMenuInteractionDelegate {
    @available(iOS 16.0, *)
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        var actions = suggestedActions
        guard let identifier = configuration.identifier as? EditIdentifier else {
            return UIMenu(children: actions)
        }
        switch identifier {
            case .longPress:
                break
            case .textEdit:
                let indentationMenu = UIMenu(title: "", options: .displayInline, children: [
                    UIAction(title: "Cut") { (_) in
                        self.cutAction()
                    },
                    UIAction(title: "Copy") { (_) in
                        self.copyAction()
                    },
                    UIAction(title: "Paste") { (_) in
                        self.pasteAction()
                    }
                ])

                actions.append(indentationMenu)
        }

        return UIMenu(children: actions)
    }

    internal func addGestureRecognizers() {
        addLongPressGestureRecognizer()
        addTapGestureRecognizer()
        addDoubleTapGestureRecognizer()
        addTripleTapGestureRecognizer()
    }

    func scrollToVisible(_ rect: CGRect) {
        scrollRectToVisible(rect, animated: true)
    }

    private func addLongPressGestureRecognizer() {
        let longPressGestureRecognizer =
        UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressGestureRecognizer)
    }

    private func presentEditMenu(_ point: CGPoint, identifier: EditIdentifier) {
                if #available(iOS 16.0, *) {
            let configuration = UIEditMenuConfiguration(identifier: identifier, sourcePoint: point)
            if let interaction = editMenuInteraction as? UIEditMenuInteraction {
                interaction.presentEditMenu(with: configuration)
            }
        }

    }

    @objc
    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        presentEditMenu(convertGesture(gestureRecognizer), identifier: .longPress)
    }

    private func addTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gesture.numberOfTapsRequired = 1
        addGestureRecognizer(gesture)
    }

    private func addDoubleTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        addGestureRecognizer(gesture)
    }

    private func addTripleTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTripleTap(_:)))
        gesture.numberOfTapsRequired = 3
        addGestureRecognizer(gesture)
    }

    @objc
    func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        changeCaretPosition(at: gestureRecognizer.location(in: self))
        becomeFirstResponder()
        relayout()
    }

    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        selectWord()
        presentEditMenu(convertGesture(gestureRecognizer), identifier: .textEdit)
        relayout()
    }

    @objc func handleTripleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        selectLine()
        presentEditMenu(convertGesture(gestureRecognizer), identifier: .textEdit)
        relayout()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

#endif
