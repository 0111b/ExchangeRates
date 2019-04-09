//
//  ExchangeRateListCell.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 09/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

final class ExchangeRateListCell: NibReusableTableViewCell {
    @IBOutlet private weak var sourceSymbolLabel: UILabel?
    @IBOutlet private weak var sourceDescriptionLabel: UILabel?
    @IBOutlet private weak var destinationValueLabel: UILabel?
    @IBOutlet private weak var destinationSymbolLabel: UILabel?
    @IBOutlet private weak var destinationDescriptionLabel: UILabel?
}

extension ExchangeRateListCell: ConfigurableCell {
    func set(model rate: ExchangeRate) {
        sourceSymbolLabel?.text = rate.source.code
        sourceDescriptionLabel?.text = rate.source.name
        destinationValueLabel?.text = "\(rate.rate)"
        destinationSymbolLabel?.text = rate.destination.code
        destinationDescriptionLabel?.text = rate.destination.name
    }
}
