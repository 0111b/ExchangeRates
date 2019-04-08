//
//  KeyValueStorage.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

protocol KeyValueStorage: AnyObject {
    func set<Value: Codable>(_ value: Value, for key: String)
    func get<Value: Codable>(for key: String, default defaultValue: Value) -> Value
}
