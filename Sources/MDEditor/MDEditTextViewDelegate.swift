//
//  File.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import AppKit

public protocol MDTextViewDelegate {
    func onTextChange(_ text: String)
}

extension MDTextViewDelegate {
    public func onTextChange(_ text: String) {
    }
}
