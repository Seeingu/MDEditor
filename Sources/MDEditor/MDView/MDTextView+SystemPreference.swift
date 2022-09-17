//
//  MDTextView+SystemPreference.swift
//  
//
//  Created by seeu on 2022/9/15.
//

import Foundation

extension MDTextView {

    var isDarkMode: Bool {
#if os(macOS)
        effectiveAppearance.name == .darkAqua
#else
        self.traitCollection.userInterfaceStyle == .dark
#endif
    }

}
