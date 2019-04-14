//
//  MockDataFetcher.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation
@testable import ExchangeRates

final class MockDataFetcher: NetworkDataFetcher {
    
    func data(from string: String) {
        data = string.data(using: .utf8)
    }
    
    func data<Value>(from value: Value) where Value: Encodable {
        data = try? JSONEncoder().encode(value)
    }
    
    var data: Data!
    
    var requestWasCalled = false
    var request: URLRequest!
    var decodingError: Error?
    
    func execute<FetchResult>(request: URLRequest, decode: @escaping (Data) throws -> FetchResult, completion: @escaping (Result<FetchResult, DataFetchError>) -> Void) -> Disposable {
        requestWasCalled = true
        self.request = request
        do {
            let result = try decode(data)
            completion(.success(result))
        } catch let error {
            self.decodingError = error
            completion(.failure(.parsingError(error)))
        }
        return Disposable.empty
    }
}
