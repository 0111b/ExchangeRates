//
//  AddCurrencyPairFlow.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

final class AddCurrencyPairFlow {
    init(currencies: [Currency], existingPairs: [CurrencyPair], completion: @escaping (CurrencyPair) -> Void) {
        availableCurrencies = currencies
        self.existingPairs = existingPairs
        complete = completion
    }

    func run(on presenter: UIViewController) {
        let selector = makeSelector(title: "First", disabled: Set()) { [unowned self] currency in
            self.didSelectFirst(currency: currency)
        }
        navigationController = UINavigationController(rootViewController: selector)
        presenter.present(navigationController, animated: true)
    }

    private func didSelectFirst(currency firstCurrency: Currency) {
        var disabled: Set<Currency.Code> = Set(
            self.existingPairs
                .filter { $0.first.code == firstCurrency.code }
                .map { $0.second.code }
        )
        disabled.insert(firstCurrency.code)
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
    private let existingPairs: [CurrencyPair]
    private let complete: (CurrencyPair) -> Void
    private lazy var navigationController = UINavigationController()

    private func makeSelector(title: String,
                              disabled: Set<Currency.Code>,
                              action: @escaping (Currency) -> Void) -> CurrencySelectorViewController {
        let controller = CurrencySelectorViewController(currencies: availableCurrencies, disabled: disabled)
        controller.title = title
        controller.didSelectItem = action
        return controller
    }
}
