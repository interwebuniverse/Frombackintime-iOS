//
//  URLHelper.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import UIKit

@MainActor enum URLHelper {
    static func open(_ url: URL?) async {
        guard let url else { return }
        _ = await UIApplication.shared.open(url, options: [:])
    }
    
    static func open(_ urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        _ = await UIApplication.shared.open(url, options: [:])
    }
}
