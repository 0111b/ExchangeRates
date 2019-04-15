//
//  ObservableCollector.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 15/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation
@testable import ExchangeRates

final class ObservableCollector<Value> {
    init(observable: Observable<Value>, skipCurrent: Bool = false) {
        disposable = observable.observe(skipCurrent: skipCurrent) { [unowned self] value in
            self.values.append(value)
        }
    }
    private var disposable = Disposable.empty
    private(set) var values = [Value]()
    var last: Value { return values.last! } //swiftlint:disable:this force_unwrapping
}
