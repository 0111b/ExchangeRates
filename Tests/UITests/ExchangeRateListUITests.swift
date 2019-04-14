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

    func testError() {
        app.launchEnvironment["SELECTED_PAIRS"] = ""
        app.launch()
//
//        let reorderButton = app/*@START_MENU_TOKEN@*/.tables["ratesList"].buttons["Reorder 1 Danish Krone is equal to 0.56 Brazilian Real"]/*[[".otherElements[\"ExchangeRatesScreen\"].tables[\"ratesList\"]",".cells[\"1 Danish Krone is equal to 0.56 Brazilian Real\"].buttons[\"Reorder 1 Danish Krone is equal to 0.56 Brazilian Real\"]",".cells[\"DKKBRL\"].buttons[\"Reorder 1 Danish Krone is equal to 0.56 Brazilian Real\"]",".buttons[\"Reorder 1 Danish Krone is equal to 0.56 Brazilian Real\"]",".tables[\"ratesList\"]"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
//        reorderButton/*@START_MENU_TOKEN@*/.press(forDuration: 0.8);/*[[".tap()",".press(forDuration: 0.8);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        reorderButton.swipeDown()
//        reorderButton.swipeUp()
//        app/*@START_MENU_TOKEN@*/.tables["ratesList"].buttons["Reorder 1 Brazilian Real is equal to 0.36 Canadian Dollar"]/*[[".otherElements[\"ExchangeRatesScreen\"].tables[\"ratesList\"]",".cells[\"1 Brazilian Real is equal to 0.36 Canadian Dollar\"].buttons[\"Reorder 1 Brazilian Real is equal to 0.36 Canadian Dollar\"]",".cells[\"BRLCAD\"].buttons[\"Reorder 1 Brazilian Real is equal to 0.36 Canadian Dollar\"]",".buttons[\"Reorder 1 Brazilian Real is equal to 0.36 Canadian Dollar\"]",".tables[\"ratesList\"]"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.swipeUp()
//        exchangeRatesNavigationBar/*@START_MENU_TOKEN@*/.buttons["addButton"]/*[[".buttons[\"Add\"]",".buttons[\"addButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }

}
