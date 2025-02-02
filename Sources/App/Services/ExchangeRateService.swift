//
//  ExchangeRateService.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

protocol ExchangeRateServiceProtocol {
    /// Fetch exchange rate information for the given currency pairs
    ///
    /// - Parameters:
    ///   - pairs: list of the currency pairs
    ///   - completion: fetch result handler
    /// - Returns: Cancelation token
    func getRates(for pairs: [CurrencyPair], completion: @escaping (Result<[ExchangeRate], DataFetchError>) -> Void) -> Disposable
}

final class ExchangeRateService: ExchangeRateServiceProtocol {
    init(config: NetworkConfig, fetcher: NetworkDataFetcher = BasicNetworkFetcher()) {
        self.baseURL = config.apiBaseURL
        self.fetcher = fetcher
    }

    func getRates(for pairs: [CurrencyPair], completion: @escaping (Result<[ExchangeRate], DataFetchError>) -> Void) -> Disposable {
        guard !pairs.isEmpty else {
            completion(.success([]))
            return Disposable.empty
        }
        guard let request = GetRatesRequest(pairs: pairs).buildRequest(against: baseURL) else {
            completion(.failure(.invalidRequest))
            return Disposable.empty
        }
        let transform: ([String: ExchangeRate.Rate]) throws -> [ExchangeRate] = { rawDictionary in
            // map raw strings to currency pairs
            let dictionary: [CurrencyPair: ExchangeRate.Rate] = try Dictionary(uniqueKeysWithValues: rawDictionary
                .map { code, rate in
                    let pair = try CurrencyPair(rawValue: code)
                    return (pair, rate)
            })
            // associate rate values with source pairs
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
