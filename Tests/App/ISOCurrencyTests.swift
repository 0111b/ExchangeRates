//
//  ISOCurrencyTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 13/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates

class ISOCurrencyTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSuccessCreation() {
        let validCodes = [
            "AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK",
            "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "ISK",
            "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN",
            "RON", "RUB", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"
        ]
        for code in validCodes {
            var currency: Currency?
            XCTAssertNoThrow(currency = try CurrencyFactory.make(from: code), "Could not create \(code)")
            XCTAssertNotNil(currency?.symbol, "Empty symbol for \(code)")
            XCTAssertNotNil(currency?.name, "Empty name for \(code)")
        }
    }

    func testInvalidCodeFail() {
        for code in ["AAA", "INVALID", "Bla-bla", "Rub", "ruB", "RUb"] {
            XCTAssertThrowsError(try CurrencyFactory.make(from: code), "Invalid ISO currency created \(code)") { error in
                guard case CurrencyFactory.Error.invalidCode(let wrongCode) = error, wrongCode == code else {
                    return XCTFail("Invalid error \(error)")
                }
            }
        }
    }
}
