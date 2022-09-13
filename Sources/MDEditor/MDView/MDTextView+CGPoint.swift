//
//  MDTextView+CGPoint.swift
//  
//
//  Created by seeu on 2022/9/13.
//

import Foundation

#if os(macOS)

#else
import UIKit
extension MDTextView {
    func convertGesture(_ gestureRecognizer: UIGestureRecognizer) -> CGPoint {
        var point = gestureRecognizer.location(in: self)
        point.x -= padding
        return point
    }

}
#endif
