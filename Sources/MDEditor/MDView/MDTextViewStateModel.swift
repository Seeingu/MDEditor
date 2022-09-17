//
//  MDTextViewStateModel.swift
//  
//
//  Created by seeu on 2022/9/16.
//

import Foundation
import MDTheme
#if os(macOS)
import AppKit
#else
import UIKit
#endif

internal class MDTextViewStateModel {
    internal var lines: [MDSourceLineInfo] = []
    internal var textViewDelegate: MDTextViewDelegate?

    internal var textLayoutManager: NSTextLayoutManager!

    internal var themeProvider: ThemeProvider = ThemeProvider.default

    internal var textContentStorage: NSTextContentStorage!

    internal var contentLayer: CALayer!
    internal var selectionLayer: CALayer!
    internal var backgroundLayer: CALayer!
    internal var fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer>!

    internal var isEditable: Bool = true

    internal var mdAttrs: [MDSourceAttribute] = []

}
