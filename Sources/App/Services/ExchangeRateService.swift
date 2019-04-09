//
//  ExchangeRateService.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

protocol ExchangeRateServiceProtocol {
    func getRates(for pairs: [CurrencyPair], completion: @escaping (Result<[ExchangeRate], DataFetchError>) -> Void) -> Disposable
}

final class ExchangeRateService: ExchangeRateServiceProtocol {
    init(config: NetworkConfig, fetcher: NetworkDataFetcher = BasicNetworkFetcher()) {
        self.baseURL = config.apiBaseURL
        self.fetcher = fetcher
    }

    func getRates(for pairs: [CurrencyPair], completion: @escaping (Result<[ExchangeRate], DataFetchError>) -> Void) -> Disposable {
        guard let request = GetRatesRequest(pairs: pairs).buildRequest(against: baseURL) else {
            completion(.failure(.invalidRequest))
            return Disposable.empty
        }
        let transform: (CurrencyPairDictionary<ExchangeRate.Rate>) -> [ExchangeRate] = { dictionary in
            return pairs.map { pair in
                let rate: ExchangeRate.Rate = dictionary[pair] ?? 0.0
                return ExchangeRate(rate: rate, currencies: pair)
            }
        }
        return fetcher.execute(request: request, transform: transform, completion: completion)
    }

    private let baseURL: URL
    private let fetcher: NetworkDataFetcher
}

private final class GetRatesRequest: HTTPRequest {
    init(pairs: [CurrencyPair]) {
        let queryItems = pairs.map {
            URLQueryItem(name: "pairs", value: $0.rawValue)
        }
        super.init(path: "revolut-ios", query: queryItems)
    }
}

/// Wrap `Dictionary` with `CurrencyPair` as a key.
///
/// required due to the way how `Decodable` is implemented in the `Dictionary`
///
/// see [implementation](https://github.com/apple/swift/blob/master/stdlib/public/core/Codable.swift.gyb)
/// for more details
///
private struct CurrencyPairDictionary<Value: Decodable>: Sequence, Decodable {

    typealias Storage = [CurrencyPair: Value]
    typealias Iterator = Storage.Iterator
    private var storage = Storage()

    func makeIterator() -> Iterator {
        return storage.makeIterator()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CurrencyPairDictionaryCodingKey.self)
        for rawKey in container.allKeys {
            let key = try CurrencyPair(rawValue: rawKey.stringValue)
            let value = try container.decode(Value.self, forKey: rawKey)
            storage[key] = value
        }
    }

    subscript(key: Storage.Key) -> Storage.Value? {
        return storage[key]
    }

    /// convenience constructor
    init(_ values: Storage) {
        storage = values
    }

}

/// Private `CodingKey` used in the `CurrencyPairDictionary`
private struct CurrencyPairDictionaryCodingKey: CodingKey {
    internal let stringValue: String
    internal let intValue: Int?

    internal init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }
    internal init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
