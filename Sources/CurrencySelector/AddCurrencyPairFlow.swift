//
//  AddCurrencyPairFlow.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

final class AddCurrencyPairFlow {
    init(currencies: [Currency], completion: @escaping (CurrencyPair) -> Void) {
        availableCurrencies = currencies
        complete = completion
    }

    func run(on presenter: UIViewController) {
        let disabled = Set<Currency.Code>()
        let selector = makeSelector(title: "First", disabled: disabled) { [unowned self] currency in
            self.didSelectFirst(currency: currency)
        }
        navigationController = UINavigationController(rootViewController: selector)
        presenter.present(navigationController, animated: true)
    }

    private func didSelectFirst(currency firstCurrency: Currency) {
        let disabled = Set<Currency.Code>(arrayLiteral: firstCurrency.code)
        let selector = makeSelector(title: "Second", disabled: disabled) { [unowned self] secondCurrency in
            self.didSelect(pair: CurrencyPair(first: firstCurrency, second: secondCurrency))
        }
        navigationController.pushViewController(selector, animated: true)
    }

    private func didSelect(pair: CurrencyPair) {
        self.navigationController.dismiss(animated: true, completion: { [unowned self] in
            self.complete(pair)
        })
    }

    private let availableCurrencies: [Currency]
    private let complete: (CurrencyPair) -> Void
    private lazy var navigationController = UINavigationController()

    private func makeSelector(title: String,
                              disabled: Set<Currency.Code>,
                              action: @escaping (Currency) -> Void) -> CurrencySelectorViewController {
        let controller = CurrencySelectorViewController(currencies: availableCurrencies, disabled: disabled)
        controller.title = "Hello"
        controller.didSelectItem = action
        return controller
    }
}
