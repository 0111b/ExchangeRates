//
//  Currency+Image.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 10/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

extension Currency {
    var flagImage: UIImage? {
        return UIImage(named: self.code) ?? UIImage(named: "UnknownCurrency")
    }
}
