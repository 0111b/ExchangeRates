//
//  UserPreferencesTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates
//swiftlint:disable force_try

class UserPreferencesTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testDidSaveSelectedPairsUpdate() {
        let storage = Storage()
        let preferences = UserPreferences(storage: storage)
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        let writeExpectation = self.expectation(description: "Write was called")
        storage.onWrite = { _, value in
            guard let selectedPairs = value as? [CurrencyPair]
                else { return XCTFail("Invalid type saved") }
            XCTAssertEqual(selectedPairs, [pair])
            writeExpectation.fulfill()
        }
        preferences.selectedPairs.value = [pair]
        self.wait(for: [writeExpectation], timeout: 1)
    }
}

private class Storage: KeyValueStorage {
    var onWrite: (String, Any) -> Void = { _, _ in }
    
    private var values = [String: Any]()
    
    func set<Value>(_ value: Value, for key: String) where Value: Decodable, Value: Encodable {
        values[key] = value
        onWrite(key, value)
    }
    
    func get<Value>(for key: String, default defaultValue: Value) -> Value where Value: Decodable, Value: Encodable {
        guard let value = values[key] as? Value else { return defaultValue }
        return value
    }
}
