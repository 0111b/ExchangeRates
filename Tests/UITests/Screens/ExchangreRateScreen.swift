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
    
    var navigationBar: XCUIElement { return app.navigationBars["Exchange rates"] }
    var doneButton: XCUIElement { return navigationBar.buttons["Done"] }
    var editButton: XCUIElement { return navigationBar.buttons["Edit"] }
    var addButton: XCUIElement { return navigationBar.buttons["Add"] }
}
