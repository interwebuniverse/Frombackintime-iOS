//
//  AppConfig.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum AppConfig: String {
    case baseHost = "BASE_HOST"
    
    func value<T: LosslessStringConvertible>() -> T? {
        guard
            let object = Bundle.main.object(forInfoDictionaryKey: self.rawValue)
        else {
            return nil
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            return T(string)
        default:
            return nil
        }
    }
}
