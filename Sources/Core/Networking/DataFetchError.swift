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
