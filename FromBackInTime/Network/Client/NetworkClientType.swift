//
//  NetworkClientType.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

protocol NetworkClientType {
    var session: URLSession { get }
    
    func request<T: Decodable>(_ request: Request) async throws -> T
    
    func requestData(from url: URL) async throws -> Data

    func uploadMultipart<T: Decodable>(request: MultipartRequest) async throws -> T

    func upload(
        _ data: Data,
        with request: Request
    ) async throws
    
    func validate(response: URLResponse, data: Data?) async throws
    
    func decode<T: Decodable>(
        with type: T.Type,
        and data: Data
    ) throws -> T
}
