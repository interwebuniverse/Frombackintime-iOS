//
//  SwipeGestureManager.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

final class SwipeGestureManager: ObservableObject {
    @Published private(set) var disabledIds = Set<String>()
    @Published private(set) var activeNavigationId: String?
    static let shared = SwipeGestureManager()

    private init() {}

    func setDisabled(_ disabled: Bool, for id: String) {
        if disabled {
            disabledIds.insert(id)
        } else {
            disabledIds.remove(id)
        }
    }

    func setActiveNavigation(_ id: String?) {
        activeNavigationId = id
    }

    var isDisabled: Bool {
        // Only disable if there are disabled IDs AND this navigation context is active
        !disabledIds.isEmpty && (activeNavigationId == nil || disabledIds.contains(activeNavigationId ?? ""))
    }
}
