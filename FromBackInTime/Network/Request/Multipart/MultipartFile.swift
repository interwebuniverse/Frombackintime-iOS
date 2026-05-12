//
//  MultipartFile.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

struct MultipartFile {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let fileData: Data
}

extension MultipartFile {
    func data(boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
}
