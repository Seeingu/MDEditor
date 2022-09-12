//
//  MDModel.swift
//  
//
//  Created by seeu on 2022/9/11.
//

import Combine
import MDTheme

class MDModel: ObservableObject {
    @Published var text: String = ""
    @Published var isEditable: Bool = true
    @Published internal var themeProvider: ThemeProvider = ThemeProvider()
}
