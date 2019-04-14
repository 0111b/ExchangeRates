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
    
    var startSelectedPairs: [CurrencyPair]? {
        guard let rawPairs = ProcessInfo.processInfo.environment["SELECTED_PAIRS"] else { return nil }
        let selectedPairs = rawPairs.split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap { try? CurrencyPair(rawValue: $0) }
        return selectedPairs.isEmpty ? [] : selectedPairs
    }
}

protocol NetworkConfig {
    var apiBaseURL: URL { get }
}

extension ApplicationConfig: NetworkConfig {}
