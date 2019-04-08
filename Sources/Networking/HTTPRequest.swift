//
//  HTTPRequest.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

/// URLRequest builder
class HTTPRequest {

    /// HTTP method definitions.
    ///
    /// See [spec](https://tools.ietf.org/html/rfc7231#section-4.3)
    enum Method: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }

    /// HTTP headers type
    typealias Headers = [String: String]

    init(path: String, query: [URLQueryItem] = [], method: Method = .get, headers: Headers = [:]) {
        self.path = path
        self.queryItems = query
        self.method = method
        self.headers = headers
    }
    
    private let path: String
    private let queryItems: [URLQueryItem]
    private let method: Method
    private let headers: Headers

    func buildRequest(against baseURL: URL) -> URLRequest? {
        let targetURL = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: targetURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = queryItems
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
}
