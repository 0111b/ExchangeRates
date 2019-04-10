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

    private func description(for currency: Currency, font: UIFont, format: String) -> NSAttributedString {
        let text = Localized(format: format, currency.name ?? "")
        let resultString = NSMutableAttributedString(string: text)
        if let imageRange = text.range(of: "<flag>"),
           let image = currency.flagImage {
            let attatchment = NSTextAttachment()
            attatchment.image = image
            attatchment.bounds = CGRect(x: 0,
                                        y: (font.capHeight - image.size.height).rounded() / 2,
                                        width: image.size.width,
                                        height: image.size.height)
            let attatchmentString = NSAttributedString(attachment: attatchment)
            resultString.replaceCharacters(in: NSRange(imageRange, in: text),
                                           with: attatchmentString)
        }
        return resultString
    }
}

extension ExchangeRateListCell: ConfigurableCell {
    func set(model rate: ExchangeRate) {
        sourceSymbolLabel?.text = rate.source.code
        sourceDescriptionLabel.map { label in
            label.attributedText = self.description(for: rate.source,
                                                    font: label.font,
                                                    format: "ExchangeRateList.Source.Description")
        }
        destinationValueLabel?.text = "\(rate.rate)"
        destinationSymbolLabel?.text = rate.destination.code
        destinationDescriptionLabel.map { label in
            label.attributedText = self.description(for: rate.destination,
                                                    font: label.font,
                                                    format: "ExchangeRateList.Destination.Description")
        }
    }
}
