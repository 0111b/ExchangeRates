//
//  Currency.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

/// Currency description
protocol Currency {
    var code: String { get }
    var symbol: String? { get }
    var name: String? { get }
}

/// Currencies namespace
enum Currencies {

    /// Factory method for creating `Currency`
    ///
    /// - Parameter code: currency code
    /// - Returns: new currency instance
    /// - Throws: `Currencies.Error.invalidCode`
    static func make(from code: String) throws -> Currency {
        switch code {
        // ISO currency
        case let isoCode where Locale.isoCurrencyCodes.contains(code):
            return try ISOCurrency(code: isoCode)
        // Decoding error
        default:
            throw Error.invalidCode(code)
        }
    }

    /// Currency related errors
    ///
    /// - invalidCode: invalid currency code passed
    enum Error: Swift.Error, LocalizedError {
        case invalidCode(String)

        var errorDescription: String? {
            switch self {
            case .invalidCode(let code): return Localized(format: "Currency.Error.InvalidCode", code)
            }
        }
    }

    /// Subset of the ISO 4217 currencies supported by the current locale
    final class ISOCurrency: Currency {
        let code: String
        let symbol: String?
        let name: String?

        init(code rawCode: String) throws {
            let localeIdentifier = "\(Locale.current.identifier)@currency=\(rawCode)"
            let locale = Locale(identifier: Locale.canonicalIdentifier(from: localeIdentifier))
            guard let currencyCode = locale.currencyCode else { throw Error.invalidCode(rawCode) }
            code = currencyCode
            symbol = locale.currencySymbol
            name = locale.localizedString(forCurrencyCode: currencyCode)
        }
    }
}
