//
//  MDTextView+SystemPreference.swift
//  
//
//  Created by seeu on 2022/9/15.
//

import Foundation

extension MDTextView {
    #if os(macOS)
    var isDarkMode: Bool {
        effectiveAppearance.name == .darkAqua
    }
    #endif
}
