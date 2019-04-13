//
//  ObservableTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates

class ObservableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testValues() {
        let observable = MutableObservable<Int>(value: 0)
        let collector = ObservableCollector(observable: observable)
        observable.value = 1
        observable.value = 2
        XCTAssertEqual(collector.values, [0, 1, 2])
    }
    
    func testSkipCurrent() {
        let observable = MutableObservable<Int>(value: 0)
        let collector = ObservableCollector(observable: observable, skipCurrent: true)
        observable.value = 1
        observable.value = 2
        XCTAssertEqual(collector.values, [1, 2])
    }

}

final class ObservableCollector<Value> {
    init(observable: Observable<Value>, skipCurrent: Bool = false) {
        disposable = observable.observe(skipCurrent: skipCurrent) { [unowned self] value in
            self.values.append(value)
        }
    }
    private var disposable = Disposable.empty
    private(set) var values = [Value]()
}
