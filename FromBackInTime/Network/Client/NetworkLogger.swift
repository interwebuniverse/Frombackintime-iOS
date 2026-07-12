//
//  NetworkLogger.swift
//  FromBackInTime
//
//  Created by Aykhan Safarli on 16.04.26.
//

import Foundation

enum NetworkLogger {
    static func log(
        request: URLRequest?,
        url: URL? = nil,
        data: Data?,
        response: URLResponse?
    ) {
        // Logging is DEBUG-only: on Release this whole body is compiled out so a
        // shipped build never prints bearer tokens, session cookies, or decrypted
        // message bodies / one-time CTM access codes to the device console.
        #if DEBUG
        let emptyMessage = "❌ IS EMPTY"

        let url = (
            request?.url?.absoluteString ?? url?.absoluteString
        ) ?? emptyMessage
        let method = request?.httpMethod ?? emptyMessage
        let headers = redacted(request?.allHTTPHeaderFields ?? [:])
        let body = request?.httpBody
        let status = (response as? HTTPURLResponse)?.statusCode ?? .zero

        print("""
        \n🔍 START LOGGING ----------------------------------
        
        🏁 STATUS CODE: \(status)
        
        🌐 URL: \(url)
        
        📩 METHOD: \(method)
        
        📌 HEADERS: \(headers.isEmpty ? emptyMessage : "\(headers as AnyObject)")
        
        """)

        logData(body, title: "📤 Request Body")
        logData(data, title: "📥 Response Data")

        print("🛑 END LOGGING ----------------------------------\n")
        #endif
    }

    /// Masks credential-bearing headers so a debug console dump can't leak a
    /// live session. Values are replaced, keys kept, so the shape stays readable.
    private static func redacted(_ headers: [String: String]) -> [String: String] {
        let sensitive: Set<String> = ["authorization", "apikey", "x-api-key", "cookie", "set-cookie"]
        return headers.reduce(into: [:]) { result, pair in
            result[pair.key] = sensitive.contains(pair.key.lowercased()) ? "‹redacted›" : pair.value
        }
    }

    private static func logData(_ data: Data?, title: String) {
        guard let data,
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("\(title): ❌ IS EMPTY\n")
            return
        }
        print("\(title): \(jsonString)\n")
    }
}
