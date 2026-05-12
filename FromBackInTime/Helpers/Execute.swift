//
//  Execute.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

enum Execute {
    static func async(block: @escaping () -> Void) {
        let workItem = DispatchWorkItem(block: block)
        DispatchQueue.main.async(execute: workItem)
    }
    
    static func after(
        _ delay: TimeInterval,
        block: @escaping () -> Void
    ) {
        let workItem = DispatchWorkItem(block: block)
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay,
            execute: workItem
        )
    }
}
