//
//  MDTextView+Layout.swift
//  
//
//  Created by seeu on 2022/9/8.
//

import Foundation

extension MDTextView {
    func relayout() {
        layer?.setNeedsLayout()
    }
}
