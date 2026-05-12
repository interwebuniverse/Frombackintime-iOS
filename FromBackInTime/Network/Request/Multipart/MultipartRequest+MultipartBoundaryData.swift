//
//  MultipartRequest+MultipartBoundaryData.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension MultipartRequest {
    func multipartBoundaryData() throws -> (Data, String) {
        let boundary = "Boundary-\(UUID().uuidString)"
        let multipartBody = NSMutableData()

        for field in self.fields {
            let fieldString = field.fieldString(boundary: boundary)
            multipartBody.appendString(fieldString)
        }
        
        for file in self.files {
            multipartBody.append(file.data(boundary: boundary))
        }
        
        multipartBody.appendString("--\(boundary)--\r\n")
        
        return (multipartBody as Data, boundary)
    }
}
