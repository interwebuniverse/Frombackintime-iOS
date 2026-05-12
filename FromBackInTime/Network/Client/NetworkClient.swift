//
//  NetworkClient.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

class NetworkClient: NetworkClientType {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func request<T: Decodable>(_ request: Request) async throws -> T {
        let urlRequest = try request.urlRequest()
        let (data, response) = try await session.data(for: urlRequest)
        
        NetworkLogger.log(request: urlRequest, data: data, response: response)
        
        return try await validate(
            response: response,
            request: request,
            data: data,
            client: self
        )
    }
    
    func requestData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        NetworkLogger.log(request: nil, url: url, data: data, response: response)
        
        try await validate(response: response)
        return data
    }
    
    func upload(_ data: Data, with request: any Request) async throws {
        let urlRequest = try request.urlRequest()
        let (responseData, response) = try await session.upload(
            for: urlRequest,
            from: data
        )
        
        NetworkLogger.log(request: urlRequest, data: responseData, response: response)
        
        try await validate(response: response)
        return
    }
    
    func uploadMultipart<T: Decodable>(
        request: MultipartRequest
    ) async throws -> T {
        var urlRequest = try request.urlRequest()
        let (body, boundary) = try request.multipartBoundaryData()
        urlRequest.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        urlRequest.setValue(
            "\(body.count)",
            forHTTPHeaderField: "Content-Length"
        )
        
        let (data, response) = try await session
            .upload(for: urlRequest, from: body)
        
        NetworkLogger.log(request: urlRequest, data: nil, response: response)
        
        var logRequest = urlRequest
        logRequest.httpBody = nil
        
        try await validate(response: response)
        return try decode(and: data)
    }
}
