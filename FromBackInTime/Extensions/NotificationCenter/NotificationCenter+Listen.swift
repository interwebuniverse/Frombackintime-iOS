//
//  NotificationCenter+Listen.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation
import Combine

extension NotificationCenter {
    static func listen(
        to notificationName: Notification.Name,
        storeIn cancellables: inout Set<AnyCancellable>,
        debounce milliSeconds: Int = .zero,
        execute action: @escaping () -> Void
    ) {
        NotificationCenter.default.publisher(for: notificationName)
            .debounce(
                for: .milliseconds(milliSeconds),
                scheduler: DispatchQueue.main
            )
            .sink { _ in
                action()
            }.store(in: &cancellables)
    }
    
    static func listen<T: Decodable>(
        to notificationName: Notification.Name,
        storeIn cancellables: inout Set<AnyCancellable>,
        decodeWith type: T.Type,
        debounce milliSeconds: Int = .zero,
        get newValue: @escaping (T) -> Void
    ) {
        NotificationCenter.default.publisher(for: notificationName)
            .debounce(
                for: .milliseconds(milliSeconds),
                scheduler: DispatchQueue.main
            )
            .sink { output in
                do {
                    guard let userInfo = output.userInfo else { return }
                    
                    let data = try JSONSerialization.data(
                        withJSONObject: userInfo
                    )
                    
                    let result = try JSONDecoder().decode(T.self, from: data)
                    
                    newValue(result)
                } catch {
                    print(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
}
