//
//  UIApplication+KeyWindow.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .keyWindow
    }
}
