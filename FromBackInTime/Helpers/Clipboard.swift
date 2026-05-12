//
//  Clipboard.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import UIKit

enum Clipboard {
    static func get() -> String {
        return UIPasteboard.general.string ?? ""
    }
    
    static func copy(text: String) {
        UIPasteboard.general.string = text
        Haptics.notification(type: .success)
    }
}
