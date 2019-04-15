//
//  UserPreferences.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

/// Runtime user preferences
///
/// Backed by the `KeyValueStorage`
final class UserPreferences {
    /// Creates instance backed by `storage`.
    /// If `selectedPairs` is set then ignores initial value in the storage
    /// - Parameters:
    ///   - storage: key-value storage
    ///   - selectedPairs: initial pairs
    init(storage: KeyValueStorage, selectedPairs: [CurrencyPair]? = nil) {
        self.storage = storage
        startSelectedPairs = selectedPairs
    }

    /// Timer refresh interval
    var refreshInterval: TimeInterval {
        return self.get(for: .refreshInterval, default: 1.0)
    }
    
    /// Supported list of the currencies
    var availableCurrencies: [Currency] {
        return self
            .get(for: .availableCurrencies, default: defaultCurrencies())
            .sorted()
            .compactMap { try? CurrencyFactory.make(from: $0) }
    }

    /// Mutable pairs selected by user
    private(set) lazy var selectedPairs: MutableObservable<[CurrencyPair]> = self.makeSelectedPairs()

    // MARK: - Private interface -

    private func makeSelectedPairs() -> MutableObservable<[CurrencyPair]> {
        let pairs: [CurrencyPair] = startSelectedPairs ?? self.get(for: .selectedCurrencyPairs, default: [])
        let observable = MutableObservable<[CurrencyPair]>(value: pairs)
        self.selectedPairsObservation = observable.observe(skipCurrent: true) { [unowned self] pairs in
                self.set(pairs, for: .selectedCurrencyPairs)
        }
        return observable
    }

    private let storage: KeyValueStorage
    private let startSelectedPairs: [CurrencyPair]?
    private var selectedPairsObservation = Disposable.empty

    private lazy var syncQueue = DispatchQueue(label: "com.revolut.UserPreferences.sync",
                                               qos: .utility,
                                               attributes: .concurrent)

    private func set<Value: Swift.Codable>(_ value: Value, for key: PreferencesKey) {
        syncQueue.async(flags: .barrier) { [storage] in
            storage.set(value, for: key.rawValue)
        }
    }

    private func get<Value: Swift.Codable>(for key: PreferencesKey, default defaultValue: Value) -> Value {
        return syncQueue.sync { [unowned storage] in
            return storage.get(for: key.rawValue, default: defaultValue)
        }
    }

    private enum PreferencesKey: String {
        case selectedCurrencyPairs
        case refreshInterval
        case availableCurrencies
    }
}

/// Default list of the available currencies
///
/// - Returns: array of the currency codes
private func defaultCurrencies() -> [Currency.Code] {
    return [
        "AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK",
        "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR",
        "ISK", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP",
        "PLN", "RON", "RUB", "SEK", "SGD", "THB", "USD", "ZAR"
    ]
}
