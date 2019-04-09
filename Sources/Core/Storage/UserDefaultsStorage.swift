//
//  UserDefaultsStorage.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation
import os.log

final class UserDefaultsStorage: KeyValueStorage {
    init(userDefaults: UserDefaults = .standard) {
        self.storage = userDefaults
    }

    private let storage: UserDefaults

    func set<Value>(_ value: Value, for key: String) where Value: Codable {
        os_log(.info, log: Log.persistence, "UserDefaultsStorage: set value <%@>", key)
        guard let data = try? PropertyListEncoder().encode(Box(value: value)) else {
            os_log(.error, log: Log.persistence, "Error encoding %{public}@", "\(type(of: value))")
            return
        }
        storage.set(data, forKey: key)
    }

    func get<Value>(for key: String, default defaultValue: Value) -> Value where Value: Codable {
        os_log(.debug, log: Log.persistence, "UserDefaultsStorage: get value <%@>", key)
        guard let data = storage.data(forKey: key) else {
            return defaultValue
        }
        guard let value = try? PropertyListDecoder().decode(Box<Value>.self, from: data).value else {
            os_log(.error, log: Log.persistence, "Could not decode %{public}@", key)
            return defaultValue
        }
        return value
    }

    // used as a root key in the property list coders
    private struct Box<T: Swift.Codable>: Swift.Codable {
        let value: T
    }
}
