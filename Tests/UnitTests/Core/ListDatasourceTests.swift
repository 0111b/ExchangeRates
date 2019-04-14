//
//  ListDatasourceTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates
import UIKit

class ListDatasourceTests: XCTestCase {
    
    var tableView: UITableView!

    override func setUp() {
        super.setUp()
        tableView = UITableView()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSetItems() {
        let datasource = ListDatasource<Model, Cell>(tableView, configure: { _, _ in })
        let items = [
            Model(value: 0),
            Model(value: 1),
            Model(value: 2),
            Model(value: 3)
        ]
        datasource.set(items: items)
        XCTAssertEqual(datasource.items, items)
        XCTAssertEqual(datasource.tableView(tableView, numberOfRowsInSection: 0), items.count)
        for (index, model) in items.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            XCTAssertEqual(datasource.item(at: indexPath), model)
        }
    }
}

private class Cell: NibReusableTableViewCell {}
private struct Model: Equatable {
    let value: Int
}
