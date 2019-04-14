//
//  AppCoordinatorTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates
import UIKit

class AppCoordinatorTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testWindowIsKey() {
        let window = WindowStub()
        let coordinator = AppCoordinator(mainWindow: window)
        coordinator.start()
        XCTAssertTrue(window.makeKeyAndVisibleCalled)
        XCTAssertNotNil(window.rootViewController)
    }
}

private class WindowStub: UIWindow {
    var makeKeyAndVisibleCalled = false
    override func makeKeyAndVisible() {
        makeKeyAndVisibleCalled = true
    }
}
