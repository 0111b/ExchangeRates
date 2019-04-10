//
//  DataFetchError.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

/// Data fetching error
///
/// - invalidRequest: invalid request
/// - networkError: transport error
/// - invalidResponse: invalid server response
/// - parsingError: recieved data parsing error
enum DataFetchError: Error {
    case invalidRequest
    case networkError(Error)
    case invalidResponse(URLResponse?)
    case parsingError(Error)
}

extension DataFetchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidRequest: return Localized("DataFetchError.InvalidRequest")
        case .networkError(let error): return error.localizedDescription
        case .invalidResponse: return Localized("DataFetchError.InvalidResponse")
        case .parsingError(let error): return error.localizedDescription
        }
    }
}

extension DataFetchError {
    var isNetworkCancel: Bool {
        guard case .networkError(let error) = self,
            (error as NSError).code == NSURLErrorCancelled
            else { return false }
        return true
    }
}
