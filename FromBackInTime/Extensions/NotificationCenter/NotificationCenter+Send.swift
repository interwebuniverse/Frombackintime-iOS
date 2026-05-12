//
//  NotificationCenter+Send.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension NotificationCenter {
    static func send<U: Encodable>(
        notification name: Notification.Name,
        with object: U
    ) {
        do {
            let data = try JSONEncoder().encode(object)
            
            let userInfo = try JSONSerialization
                .jsonObject(with: data) as? [String: Any]
            
            NotificationCenter.default.post(
                name: name,
                object: nil,
                userInfo: userInfo
            )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func send(
        notification name: Notification.Name
    ) {
        NotificationCenter.default.post(name: name, object: nil)
    }
}
