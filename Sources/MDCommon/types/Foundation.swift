//
//  Foundation.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import AppKit

public typealias StringAttributes = [NSAttributedString.Key: Any]

extension StringAttributes {
    public func merging(_ other: StringAttributes) -> Self {
        self.merging(other) { (_, new) in new }
    }
}
