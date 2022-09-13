//
//  MDTextView+NSTextLayoutManagerDelegate.swift
//  
//
//  Created by seeu on 2022/9/7.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension MDTextView: NSTextLayoutManagerDelegate {
    func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
                           textLayoutFragmentFor location: NSTextLocation,
                           in textElement: NSTextElement) -> NSTextLayoutFragment {
        return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
}
