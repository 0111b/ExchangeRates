//
//  Cancellable.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

protocol Cancellable {
    func cancel()
}

struct StubCancellable: Cancellable {
    func cancel() {
    }
}
