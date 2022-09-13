//
//  Pasteboard.swift
//  
//
//  Created by seeu on 2022/9/12.
//

import Foundation

#if os(macOS)
import AppKit

public struct MDPasteboard {
    public static func writeToPasteboard(with text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([text as NSPasteboardWriting])
    }

    public static func readPasteboard() -> String? {
        return NSPasteboard.general.string(forType: .string)
    }
}

#else
import UIKit

public struct MDPasteboard {
    public static func writeToPasteboard(with text: String) {
        UIPasteboard.general.string = text
    }

    public static func readPasteboard() -> String? {
        return UIPasteboard.general.string
    }

}
#endif
