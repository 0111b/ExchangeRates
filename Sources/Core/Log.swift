//
//  Log.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 09/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation
import os.log

enum Log {
    //swiftlint:disable:next force_unwrapping
    private static var subsystem: String { return Bundle.main.bundleIdentifier! }
    static let networking = OSLog(subsystem: subsystem, category: "Networking")
    static let persistence = OSLog(subsystem: subsystem, category: "Persistence")
    static let general = OSLog(subsystem: subsystem, category: "General")
    static let pointsOfInterest = OSLog(subsystem: subsystem, category: .pointsOfInterest)
}
