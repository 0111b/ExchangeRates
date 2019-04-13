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


}
