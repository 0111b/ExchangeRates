//
//  ExchangeRateListViewController.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

class ExchangeRateListViewController: UIViewController {
    private lazy var service: ExchangeRateServiceProtocol = {
        //swiftlint:disable:next force_unwrapping
        let url = URL(string: "https://europe-west1-revolut-230009.cloudfunctions.net")!
        return ExchangeRateService(baseURL: url)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let usd = try CurrencyFactory.make(from: "USD")
            let gbp = try CurrencyFactory.make(from: "GBP")
            let pairs = [
                CurrencyPair(first: usd, second: gbp),
                CurrencyPair(first: gbp, second: usd)
            ]
            service.getRates(for: pairs) { result in
                print(result)
            }
        } catch {
            print(error)
        }
    }
}
