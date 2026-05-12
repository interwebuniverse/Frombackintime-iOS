//
//  FileHelper.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum FileHelper {
    static func getFile<T: Decodable>(
        forResource: String,
        withExtension: String,
        andType: T.Type
    ) -> T? {
        guard let url = Bundle.main.url(
            forResource: forResource,
            withExtension: withExtension
        ) else { return nil }
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        return try? JSONDecoder()
            .decode(T.self, from: data)
    }
}
