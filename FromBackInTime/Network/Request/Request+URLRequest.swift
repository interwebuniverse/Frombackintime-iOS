//
//  Request+URLRequest.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

extension Request {
    func urlRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppConfig.baseHost.value()
        urlComponents.path = path
        urlComponents.queryItems = queries?.map {
            URLQueryItem(name: $0, value: $1)
        }
        
        var urlRequestURL: URL? {
            guard let fullPath else {
                return urlComponents.url
            }
            return URL(string: fullPath)
        }
        
        guard let url = urlRequestURL else { throw NetworkError.urlParsing }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if let httpBody {
            // Let an encode failure throw rather than quietly sending a bodyless
            // request the server would reject with a confusing 400.
            urlRequest.httpBody = try JSONEncoder.dateEncoder.encode(httpBody)
        }
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}
