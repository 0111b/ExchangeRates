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

    private func description(for currency: Currency, format: String) -> NSAttributedString {
        let text = Localized(format: format, currency.name ?? "")
        let font = UIFont.preferredFont(forTextStyle: .body)
        let textColor = UIColor.black
        let resultString = NSMutableAttributedString(string: text,
                                                     attributes: [
                                                        .font: font,
                                                        .foregroundColor: textColor
            ])
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

    static let defaultRowHeight: CGFloat = 98.0
}

extension ExchangeRateListCell: ConfigurableCell {
    func set(model rate: ExchangeRate) {
        sourceSymbolLabel?.text = rate.source.code
        sourceDescriptionLabel.map { label in
            label.attributedText = self.description(for: rate.source,
                                                    format: "ExchangeRateList.Source.Description")
        }
        destinationValueLabel?.text = "\(rate.rate)"
        destinationSymbolLabel?.text = rate.destination.code
        destinationDescriptionLabel.map { label in
            label.attributedText = self.description(for: rate.destination,
                                                    format: "ExchangeRateList.Destination.Description")
        }
        let accesibilityName: (Currency) -> String = {
            return $0.name ?? $0.code
        }
        self.accessibilityLabel = Localized(format: "ExchangeRateList.AccessibilityLabel",
                                            accesibilityName(rate.source), rate.rate, accesibilityName(rate.destination))
    }
}
