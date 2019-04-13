//
//  UserDefaultsStorageTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 13/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates

class UserDefaultsStorageTests: XCTestCase {
    
    var userDefaults: UserDefaults!
    var storage: UserDefaultsStorage!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        storage = UserDefaultsStorage(userDefaults: userDefaults)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWtite() {
        func write<Value: Codable>(_ value: Value, key: String) {
            XCTAssertNil(userDefaults.object(forKey: key))
            storage.set(value, for: key)
            XCTAssertNotNil(userDefaults.object(forKey: key))
        }
        write(42, key: "Int")
        write(3.14, key: "Float")
        write("Helo", key: "String")
        write([1, 2, 3], key: "Array")
        write(["foo": "bar"], key: "Dictionary")
    }
    
    func testDefaultValue() {
        let key = "something"
        XCTAssertNil(userDefaults.object(forKey: key))
        XCTAssertEqual("Value", storage.get(for: key, default: "Value"))
    }
    
    func testWriteRead() {
        let key = "something"
        let value = "Value"
        XCTAssertNil(userDefaults.object(forKey: key))
        storage.set(value, for: key)
        XCTAssertEqual(value, storage.get(for: key, default: "Other value"))
    }
    
    func testInvalidDataToDefault() {
        let key = "something"
        XCTAssertNil(userDefaults.object(forKey: key))
        userDefaults.setValue("Hello", forKeyPath: key)
        XCTAssertEqual(42, storage.get(for: key, default: 42))
    }

    func testInvalidFormatToDefault() {
        let key = "something"
        XCTAssertNil(userDefaults.object(forKey: key))
        struct DataTypeV1: Codable {
            let data: String
        }
        struct DataTypeV2: Codable, Equatable {
            let data: Int
        }
        let version1 = DataTypeV1(data: "V1")
        storage.set(version1, for: key)
        let version2 = DataTypeV2(data: 42)
        XCTAssertEqual(storage.get(for: key, default: version2), version2)
    }
}
