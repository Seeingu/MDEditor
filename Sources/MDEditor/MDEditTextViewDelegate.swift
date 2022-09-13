//
//  MDEditTextViewDelegate.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import Foundation

public protocol MDTextViewDelegate {
    func onTextChange(_ text: String)
}

extension MDTextViewDelegate {
    public func onTextChange(_ text: String) {
    }
}
