//
//  Router.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class Router {
    static var base = Router()
    
    var paths: [RouterDestination] = []
    
    var sheet: RouterDestination?
    var fullScreenSheet: RouterDestination?
    
    var selectedTab = 0
    
    init() {}
    
    func popToRoot() {
        paths = []
    }
    
    func popLast() {
        paths.removeLast()
    }
    
    func navigate(_ destination: RouterDestination) {
        paths.append(destination)
    }
    
    func set(_ destination: RouterDestination) {
        paths = [destination]
    }
    
    func present(_ destination: RouterDestination) {
        sheet = destination
    }

    func presentFullScreen(_ destination: RouterDestination) {
        fullScreenSheet = destination
    }
    
    func goBack() {
        if !paths.isEmpty {
            paths.removeLast()
        }
    }
}
