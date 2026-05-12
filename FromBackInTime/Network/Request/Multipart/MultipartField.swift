//
//  MultipartField.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

struct MultipartField {
    let name: String
    let value: String
}

extension MultipartField {
    func fieldString(boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        print(fieldString)
        
        return fieldString
    }
}
