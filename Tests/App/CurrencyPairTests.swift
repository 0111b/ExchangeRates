//
//  CurrencyPairTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 13/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates
//swiftlint:disable force_try

class CurrencyPairTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreationFromRawSuccess() {
        for rawPair in [
            ("USD", "RUB"),
            ("RUB", "USD"),
            ("HUF", "RUB"),
            ("USD", "TRY"),
            ("CAD", "RON")
            ] {
            var cpair: CurrencyPair!
            XCTAssertNoThrow(cpair = try CurrencyPair(rawValue: "\(rawPair.0)\(rawPair.1)"), "Cant create pair \(rawPair)")
            XCTAssertEqual(cpair.first.code, rawPair.0)
            XCTAssertEqual(cpair.second.code, rawPair.1)
        }
    }
    
    func testCreationFromRawFail() {
        XCTAssertThrowsError(try CurrencyPair(rawValue: ""))
        XCTAssertThrowsError(try CurrencyPair(rawValue: "Hello world"))
        XCTAssertThrowsError(try CurrencyPair(rawValue: "BLABLA"))
    }
    
    func testRawValue() {
        let usd = try! CurrencyFactory.make(from: "USD")
        let rub = try! CurrencyFactory.make(from: "RUB")
        XCTAssertEqual(CurrencyPair(first: usd, second: rub).rawValue, "USDRUB")
        XCTAssertEqual(CurrencyPair(first: rub, second: usd).rawValue, "RUBUSD")
    }
    
    func testEquality() {
        let usd = try! CurrencyFactory.make(from: "USD")
        let rub = try! CurrencyFactory.make(from: "RUB")
        XCTAssertEqual(CurrencyPair(first: usd, second: rub),
                       CurrencyPair(first: usd, second: rub))
        XCTAssertEqual(CurrencyPair(first: usd, second: usd),
                       CurrencyPair(first: usd, second: usd))
        XCTAssertEqual(CurrencyPair(first: rub, second: usd),
                       CurrencyPair(first: rub, second: usd))
        XCTAssertNotEqual(CurrencyPair(first: usd, second: rub),
                          CurrencyPair(first: rub, second: usd))
    }
    
    func testDecodable() {
        let rawCode = "USDRUB"
        let json = ["key": rawCode]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        typealias DataType = [String: CurrencyPair]
        var result: DataType!
        XCTAssertNoThrow(result = try JSONDecoder().decode(DataType.self, from: data), "Could not decode pair")
        XCTAssertNotNil(result)
        XCTAssertEqual(rawCode, result["key"]?.rawValue)
    }
    
    func testEncodable() {
        let sourcePair = try! CurrencyPair(rawValue: "USDRUB")
        var data: Data!
        XCTAssertNoThrow(data = try JSONEncoder().encode(["key": sourcePair]), "Could not encode pair")
        XCTAssertNotNil(data)
    }
}
