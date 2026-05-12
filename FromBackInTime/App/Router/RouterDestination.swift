//
//  RouterDestination.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum RouterDestination: Identifiable, Hashable {
    case onboarding
    case example

    var id: String {
        switch self {
        case .onboarding: return "onboarding"
        case .example: return "example"
        }
    }
}
