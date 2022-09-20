//
//  MDTextViewStateModel.swift
//  
//
//  Created by seeu on 2022/9/16.
//

import Foundation
import MDTheme
import MDCommon
#if os(macOS)
import AppKit
#else
import UIKit
#endif

internal class MDTextViewStateModel {
    // MARK: - Textkit
    internal var textViewDelegate: MDTextViewDelegate?
    internal var textLayoutManager: NSTextLayoutManager!
    internal var textContentStorage: NSTextContentStorage!

    // MARK: - Layer
    internal var contentLayer: CALayer!
    internal var selectionLayer: CALayer!
    internal var backgroundLayer: CALayer!
    internal var fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer>!

    // MARK: - Markdown Source Info
    internal var mdAttrs: [MDSourceAttribute] = []
    internal var lines: [MDSourceLineInfo] = []

    // MARK: - Others
    internal var themeProvider: ThemeProvider = ThemeProvider.default

    internal var isEditable: Bool = true
}
