//
//  ExchangeRateListCoordinator.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 09/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit
import os.log

final class ExchangeRateListCoordinator {
    init(navigationController: UINavigationController, preferences: UserPreferences) {
        self.navigationController = navigationController
        self.preferences = preferences
    }

    func start() {
        os_log(.info, log: Log.general, "ExchangeRateListCoordinator start")
        navigationController.pushViewController(makeListController(), animated: true)
    }

    func addCurrencyPair(success: @escaping (CurrencyPair) -> Void) {
        let flow = AddCurrencyPairFlow(currencies: preferences.availableCurrencies,
                                       existingPairs: preferences.selectedPairs.value,
                                       completion: success)
        flow.run(on: navigationController)
    }

    private func makeListController() -> ExchangeRateListViewController {
        let service = ExchangeRateService(config: ApplicationConfig.current, fetcher: BasicNetworkFetcher())
        let viewModel = ExchangeRateListViewModel(pairs: preferences.selectedPairs, service: service)
        return ExchangeRateListViewController(coordinator: self, viewModel: viewModel)
    }

    private unowned let navigationController: UINavigationController
    private unowned let preferences: UserPreferences
}
