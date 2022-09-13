//
//  MDTextView+Layout.swift
//  
//
//  Created by seeu on 2022/9/8.
//

import Foundation

extension MDTextView {
    func relayout() {
        #if os(macOS)
        guard let layer = layer else {
            return
        }
        #endif
        layer.setNeedsLayout()
    }
}
