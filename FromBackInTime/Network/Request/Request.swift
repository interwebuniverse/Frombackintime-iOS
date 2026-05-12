//
//  Request.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

protocol Request {
    var fullPath: String? { get }
    var path: String { get }
    var method: RequestMethod { get }
    var httpBody: Encodable? { get }
    var queries: [String: String]? { get }
    var headers: [String: String] { get }
    var needAuth: Bool { get }
    
    func urlRequest() throws -> URLRequest
}
