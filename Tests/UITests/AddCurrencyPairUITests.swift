//
//  AddCurrencyPairUITests.swift
//  ExchangeRatesUITests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest

class AddCurrencyPairUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    func testAddingCurrencyPair() {
        app.launchEnvironment["SELECTED_PAIRS"] = ""
        app.launch()
        let selectorScreen = app.exchangreRateScreen.moveToCurrencySelector()
        selectorScreen.currencyCell("USD").tap()
        selectorScreen.currencyCell("RUB").tap()
        let listScreen = app.exchangreRateScreen
        XCTAssertTrue(listScreen.exists)
        XCTAssertTrue(listScreen.rateCell("USDRUB").exists)
    }
    
    func testNotAddingSelf() {
        app.launchEnvironment["SELECTED_PAIRS"] = ""
        app.launch()
        let selectorScreen = app.exchangreRateScreen.moveToCurrencySelector()
        selectorScreen.currencyCell("USD").tap()
        selectorScreen.currencyCell("USD").tap()
        XCTAssertFalse(app.exchangreRateScreen.rateCell("USDUSD").exists)
    }
    
    func testNotAddingExisting() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB"
        app.launch()
        let selectorScreen = app.exchangreRateScreen.moveToCurrencySelector()
        selectorScreen.currencyCell("USD").tap()
        selectorScreen.currencyCell("RUB").tap()
        XCTAssertFalse(app.exchangreRateScreen.exists)
    }
}
