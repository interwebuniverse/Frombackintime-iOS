//
//  ExampleRequests.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum ExampleRequests {
    struct ListItems: Request {
        var path: String { "/v1/example/items" }
        var method: RequestMethod { .GET }
        var needAuth: Bool { false }
    }

    struct ItemDetail: Request {
        let id: String
        var path: String { "/v1/example/items/\(id)" }
        var method: RequestMethod { .GET }
        var needAuth: Bool { false }
    }
}
