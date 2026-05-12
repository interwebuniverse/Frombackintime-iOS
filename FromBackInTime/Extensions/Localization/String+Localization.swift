//
//  String+Localization.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .main, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
