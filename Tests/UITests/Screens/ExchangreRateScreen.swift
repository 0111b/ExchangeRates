//
//  ExchangreRateScreen.swift
//  ExchangeRatesUITests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var exchangreRateScreen: ExchangreRateScreen { return ExchangreRateScreen(app: self) }
}

struct ExchangreRateScreen {
    let app: XCUIApplication
    
    var exists: Bool { return app.otherElements["ExchangeRatesScreen"].waitForExistence(timeout: 1) }

    var navigationBar: XCUIElement { return app.navigationBars["Exchange rates"] }
    var doneButton: XCUIElement { return navigationBar.buttons["doneButton"] }
    var editButton: XCUIElement { return navigationBar.buttons["editButton"] }
    var addButton: XCUIElement { return navigationBar.buttons["addButton"] }
    
    var emptyHint: XCUIElement { return app.staticTexts["emptyHintView"] }
    var errorView: XCUIElement { return app.staticTexts["errorView"] }
    
    var ratesList: XCUIElement { return app.tables["ratesList"] }
    func rateCell(_ identifier: String) -> XCUIElement {
        return ratesList.cells[identifier]
    }
}
