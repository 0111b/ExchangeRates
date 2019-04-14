//
//  ExchangeRatesUITests.swift
//  ExchangeRatesUITests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest

class ExchangeRatesUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    
        
    }

    override func tearDown() {
        super.tearDown()
        
    }
    
    func testEditStateSwitch() {
        app.launchEnvironment["SELECTED_PAIRS"] = "USDRUB, RUBUSD"
        app.launch()
        let screen = app.exchangreRateScreen
        screen.editButton.tap()
        
        screen.doneButton.tap()
    }

    func testExample() {
        app.launchEnvironment["SELECTED_PAIRS"] = ""
        app.launch()
        
        let app = XCUIApplication()
        app.staticTexts["Add a currency pair to compare their live rates"].tap()
        app.navigationBars["Exchange rates"].buttons["Add"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Brazilian Real"]/*[[".cells[\"Brazilian Real\"].staticTexts[\"Brazilian Real\"]",".staticTexts[\"Brazilian Real\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Chinese Yuan"]/*[[".cells[\"Chinese Yuan\"].staticTexts[\"Chinese Yuan\"]",".staticTexts[\"Chinese Yuan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }

}
