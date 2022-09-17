//
//  MDModel.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import SwiftUI
import MDTheme

class MDModel {
    var text: String = ""
    var isEditable: Bool = true
    var themeProvider: ThemeProvider = ThemeProvider()

    var textChangeAction: ((_ text: String) -> Void)?
}
