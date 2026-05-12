//
//  UINavigationController+SwipeGesture.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1 && !SwipeGestureManager.shared.isDisabled
    }
}
