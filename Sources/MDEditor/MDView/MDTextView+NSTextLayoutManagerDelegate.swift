//
//  MDTextView+NSTextLayoutManagerDelegate.swift
//  
//
//  Created by seeu on 2022/9/7.
//

import AppKit

extension MDTextView: NSTextLayoutManagerDelegate {
    func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
                           textLayoutFragmentFor location: NSTextLocation,
                           in textElement: NSTextElement) -> NSTextLayoutFragment {
        return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
}
