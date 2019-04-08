//
//  ExchangeRate.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

/// Exchange rate information
struct ExchangeRate {
    /// Type that represent exchange rate value
    typealias Rate = Double

    /// Exchange rate from `source` to `destination`
    let rate: Rate

    /// List of currencies
    let currencies: CurrencyPair

    /// Source currency
    var source: Currency { return currencies.first }

    /// Destination currency
    var destination: Currency { return currencies.second }
}
