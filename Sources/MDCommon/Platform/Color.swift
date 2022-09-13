//
//  Color.swift
//  
//
//  Created by seeu on 2022/9/12.
//

#if os(macOS)
import AppKit

public typealias MDColor = NSColor
#else
import UIKit

public typealias MDColor = UIColor
extension MDColor {
    public static let selectedTextBackgroundColor = MDColor.systemBlue
}
#endif
