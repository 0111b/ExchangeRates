//
//  CurrencySelectorCell.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

final class CurrencySelectorCell: UITableViewCell, NibReusableCell {
    
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var iconView: UIImageView!

    func set(currency: Currency, enabled: Bool) {
        codeLabel.text = currency.code
        nameLabel.text = currency.name
        iconView.image = currency.flagImage
        self.accessoryType = enabled ? .disclosureIndicator : .none
        self.selectionStyle = enabled ? .gray : .none
    }
}
