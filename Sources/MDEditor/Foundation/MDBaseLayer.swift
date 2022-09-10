//
//  MDLayer.swift
//  
//
//  Created by seeu on 2022/9/7.
//

import AppKit

internal class MDBaseLayer: CALayer {
    override class func defaultAction(forKey event: String) -> CAAction? {
        // Suppress default animation of opacity
        return NSNull()
    }
}
