//
//  NetworkErrorModel.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

struct NetworkErrorModel: Error, Codable {
    let message: String
}

extension Error {
    var asNetworkErrorModel: NetworkErrorModel? {
        return self as? NetworkErrorModel
    }
}
