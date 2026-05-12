//
//  String+Replace.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension String {
    var replaceSpaces: String {
        self.replacingOccurrences(of: " ", with: "")
    }
}
