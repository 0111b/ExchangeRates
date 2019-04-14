//
//  CurrencySelectorScreen.swift
//  ExchangeRatesUITests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var currencySelectorScreen: CurrencySelectorScreen { return CurrencySelectorScreen(app: self) }
}

extension ExchangreRateScreen {
    func moveToCurrencySelector() -> CurrencySelectorScreen {
        XCTAssertTrue(self.exists)
        addButton.tap()
        let screen = app.currencySelectorScreen
        XCTAssertTrue(screen.exists)
        return screen
    }
}

struct CurrencySelectorScreen {
    let app: XCUIApplication
    
    var exists: Bool { return app.otherElements["ExchangeRatesScreen"].exists }

    var currencyList: XCUIElement { return app.tables["currencyList"] }
    
    func currencyCell(_ identifier: String) -> XCUIElement {
        return currencyList.cells[identifier]
    }
}
