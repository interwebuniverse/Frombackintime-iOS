//
//  MultipartRequest.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

protocol MultipartRequest: Request {
    var fields: [MultipartField] { get }
    var files: [MultipartFile] { get }
    
    func multipartBoundaryData() throws -> (Data, String)
}
