//
//  ExchangeRateListUITests.swift
//  ExchangeRatesUITests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest

class ExchangeRateListUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["ANIMATIONS_DISABLED"] = "YES"
    }

    override func tearDown() {
        super.tearDown()
        
    }
    
    func testEmptyState() {
        app.launchEnvironment["SELECTED_PAIRS"] = ""
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        XCTAssertTrue(screen.emptyHint.exists)
        XCTAssertFalse(screen.ratesList.exists)
        XCTAssertFalse(screen.editButton.isEnabled)
    }
    
    func testNotEmptyState() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB, RUBUSD"
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        XCTAssertFalse(screen.emptyHint.exists)
        XCTAssertTrue(screen.ratesList.exists)
        XCTAssertTrue(screen.editButton.isEnabled)
        XCTAssertTrue(screen.rateCell("USDRUB").exists)
        XCTAssertTrue(screen.rateCell("RUBUSD").exists)
    }
    
    func testEditStateSwitch() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB, RUBUSD"
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        XCTAssertFalse(screen.doneButton.exists)
        XCTAssertTrue(screen.editButton.exists)
        screen.editButton.tap()
        XCTAssertTrue(screen.doneButton.exists)
        XCTAssertFalse(screen.editButton.exists)
        screen.doneButton.tap()
        XCTAssertFalse(screen.doneButton.exists)
        XCTAssertTrue(screen.editButton.exists)
    }
    
    func testItemDelete() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB, RUBUSD"
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        screen.editButton.tap()
        screen.rateCell("USDRUB").buttons.element(boundBy: 0).tap()
        screen.rateCell("USDRUB").buttons["Delete"].tap()
        XCTAssertFalse(screen.rateCell("USDRUB").exists)
    }
    
    func testDeleteInline() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB, RUBUSD"
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        screen.rateCell("USDRUB").swipeLeft()
        XCTAssertTrue(screen.doneButton.exists)
        screen.rateCell("USDRUB").buttons.element.tap()
        XCTAssertFalse(screen.rateCell("USDRUB").exists)
    }

    func testErrorHiddenNormal() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB, RUBUSD"
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        XCTAssertFalse(screen.errorView.exists)
    }
    
    func testErrorVisibleWithValues() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB, RUBUSD"
        app.launchEnvironment["NETWORK_ENABLED"] = "NO"
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        XCTAssertTrue(screen.errorView.exists)
    }

    func testErrorHiddenOnEmpty() {
        app.launchEnvironment["SELECTED_PAIRS"] = ""
        app.launchEnvironment["NETWORK_ENABLED"] = "NO"
        app.launch()
        let screen = app.exchangreRateScreen
        XCTAssertTrue(screen.exists)
        XCTAssertFalse(screen.errorView.exists)
    }
}
