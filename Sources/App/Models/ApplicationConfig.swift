//
//  ApplicationConfig.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

enum ApplicationConfig {
    case develop

    static let current: ApplicationConfig = .develop

    var apiBaseURL: URL {
        switch self {
        case .develop:
            return URL(staticString: "https://europe-west1-revolut-230009.cloudfunctions.net")
        }
    }
    
    // MARK: - Process env -
    
    var startSelectedPairs: [CurrencyPair]? {
        return ProcessInfo.processInfo
            .environment["SELECTED_PAIRS"]?
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap { try? CurrencyPair(rawValue: $0) }
    }
    
    var isNetworkingEnabled: Bool {
        let envValue = ProcessInfo.processInfo
            .environment["NETWORK_ENABLED"]
            .map { ($0 as NSString).boolValue }
        return envValue ?? true
    }
}

protocol NetworkConfig {
    var apiBaseURL: URL { get }
}

extension ApplicationConfig: NetworkConfig {}
