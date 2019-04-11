//
//  AddCurrencyPairFlow.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit
import os.log

final class AddCurrencyPairFlow: NSObject {
    init(currencies: [Currency], existingPairs: [CurrencyPair], completion: @escaping (CurrencyPair) -> Void) {
        availableCurrencies = currencies
        self.existingPairs = existingPairs
        complete = completion
    }

    func run(on presenter: UIViewController, barButtonItem: UIBarButtonItem) {
        os_log(.default, log: Log.general, "AddCurrencyPairFlow start")
        let selector = makeSelector(title: Localized("AddCurrencyPairFlow.FirstCurrency.Selector.Title"),
                                    disabled: Set()) { [self] currency in
            self.didSelectFirst(currency: currency)
        }
        navigationController = UINavigationController(rootViewController: selector)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = barButtonItem
        navigationController.popoverPresentationController?.delegate = self
        presenter.present(navigationController, animated: true)
    }

    private func didSelectFirst(currency firstCurrency: Currency) {
        var disabled: Set<Currency.Code> = Set(
            self.existingPairs
                .filter { $0.first.code == firstCurrency.code }
                .map { $0.second.code }
        )
        disabled.insert(firstCurrency.code)
        let selector = makeSelector(title: Localized("AddCurrencyPairFlow.SecondCurrency.Selector.Title"),
                                    disabled: disabled) { [self] secondCurrency in
            self.didSelect(pair: CurrencyPair(first: firstCurrency, second: secondCurrency))
        }
        navigationController.pushViewController(selector, animated: true)
    }

    private func didSelect(pair: CurrencyPair) {
        cleanup()
        self.navigationController.dismiss(animated: true, completion: { [self] in
            os_log(.default, log: Log.general, "AddCurrencyPairFlow did finish %{public}@", pair.description)
            self.complete(pair)
        })
    }

    @objc private func didCancelFlow() {
        cleanup()
        self.navigationController.dismiss(animated: true)
    }

    private func cleanup() {
        navigationController.viewControllers
            .compactMap { $0 as? CurrencySelectorViewController }
            .forEach { $0.didSelectItem = { _ in } }
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
        if UIDevice.current.userInterfaceIdiom == .phone {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                          target: self,
                                                                          action: #selector(type(of: self).didCancelFlow))
        }
        return controller
    }
}

extension AddCurrencyPairFlow: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        cleanup()
    }
}
