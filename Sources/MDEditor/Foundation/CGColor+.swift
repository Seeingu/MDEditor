//
//  CGColor+.swift
//  
//
//  Created by seeu on 2022/9/8.
//

import AppKit

extension CGColor {
    /// transform the opacity of cgcolor
    static func transform(from color: CGColor, alpha: CGFloat = 1.0) -> CGColor {
        let components = color.components!
        return CGColor(red: components[0], green: components[1], blue: components[2], alpha: alpha)
    }
}
