//
//  BaseResponse.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//
//  Generic wrapper for APIs that return `{ "data": ..., "message": "..." }`.
//  Adjust the fields to match your API's envelope shape.
//
//  Usage in repository:
//    let response: BaseResponse<ProfileResponses.Detail> = try await client.request(...)
//    return response.data

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let data: T
    let message: String?

    init(data: T, message: String? = nil) {
        self.data = data
        self.message = message
    }
}
