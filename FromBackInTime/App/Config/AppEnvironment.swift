//
//  AppEnvironment.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum AppEnvironment {
    case live
    case mock

    static var current: AppEnvironment {
        #if MOCK
        return .mock
        #else
        return .live
        #endif
    }

    var isMock: Bool { self == .mock }
}
