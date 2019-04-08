//
//  NetworkDataFetcher.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

protocol NetworkDataFetcher {
    @discardableResult
    func execute<FetchResult>(request: URLRequest,
                              decode: @escaping (Data) throws -> FetchResult,
                              completion: @escaping (Result<FetchResult, DataFetchError>) -> Void) -> Disposable
}

extension NetworkDataFetcher {
    @discardableResult
    func execute<FetchResult, RawData>(request: URLRequest,
                                       configure: @escaping (JSONDecoder) -> Void = { _ in },
                                       transform: @escaping (RawData) throws -> FetchResult,
                                       completion: @escaping (Result<FetchResult, DataFetchError>) -> Void) -> Disposable
        where RawData: Decodable {
            let decodeJSON: (Data) throws -> RawData = { data in
                let decoder = JSONDecoder()
                configure(decoder)
                return try decoder.decode(RawData.self, from: data)
            }
            let decode: (Data) throws -> FetchResult = { data in
                return try transform(decodeJSON(data))
            }
            return execute(request: request, decode: decode, completion: completion)
    }

    @discardableResult
    func execute<FetchResult>(request: URLRequest,
                              configure: @escaping (JSONDecoder) -> Void = { _ in },
                              completion: @escaping (Result<FetchResult, DataFetchError>) -> Void) -> Disposable
        where FetchResult: Decodable {
            let transform: (FetchResult) throws -> FetchResult = { return $0 }
            return execute(request: request, configure: configure, transform: transform, completion: completion)
    }
}
