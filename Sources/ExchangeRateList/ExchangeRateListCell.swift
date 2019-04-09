//
//  ExchangeRateListCell.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 09/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

final class ExchangeRateListCell: NibReusableTableViewCell {

}

extension ExchangeRateListCell: ConfigurableCell {
    func set(model: ExchangeRate) {
        self.textLabel?.text = model.description
    }
}
