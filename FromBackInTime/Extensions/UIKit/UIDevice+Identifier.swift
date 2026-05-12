//
//  UIDevice+Identifier.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import UIKit

extension UIDevice {
    static let identifier = UIDevice
        .current
        .identifierForVendor?
        .uuidString ?? UUID().uuidString
}
