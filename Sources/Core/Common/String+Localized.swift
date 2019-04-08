//
//  String+Localized.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

//TODO: better use of localization

// swiftlint:disable:next identifier_name
func Localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

// swiftlint:disable:next identifier_name
func Localized(format: String, _ value: CVarArg) -> String {
    return String.localizedStringWithFormat(Localized(format), value)
}

// swiftlint:disable:next identifier_name
func Localized(format: String, _ value1: CVarArg, _ value2: CVarArg) -> String {
    return String.localizedStringWithFormat(Localized(format), value1, value2)
}
