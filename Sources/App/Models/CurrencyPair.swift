//
//  CurrencyPair.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

struct CurrencyPair {
    let first: Currency
    let second: Currency

    var rawValue: String { return first.code.appending(second.code) }
}

extension CurrencyPair {
    init(rawValue: String) throws {
        struct FormatError: Error { let value: String }

        guard rawValue.count == 6 else {
            throw FormatError(value: rawValue)
        }
        first = try CurrencyFactory.make(from: Currency.Code(rawValue.prefix(3)))
        second = try CurrencyFactory.make(from: Currency.Code(rawValue.suffix(3)))
    }
}

extension CurrencyPair: Equatable {
    static func == (lhs: CurrencyPair, rhs: CurrencyPair) -> Bool {
        return lhs.first.code == rhs.first.code
            && lhs.second.code == rhs.second.code
    }
}

extension CurrencyPair: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(first.code)
        hasher.combine(second.code)
    }
}

extension CurrencyPair: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = try .init(rawValue: rawValue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension CurrencyPair: CustomStringConvertible {
    var description: String {
        return "Pair<\(first.description):\(second.description)>"
    }
}
