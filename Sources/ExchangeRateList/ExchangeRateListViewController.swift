//
//  ExchangeRateListViewController.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit
import os.log

final class ExchangeRateListViewController: UIViewController {
    private let viewModel = ExchangeRateListViewModel()
    private lazy var addCurrencyFlow: AddCurrencyPairFlow = {
        return AddCurrencyPairFlow(currencies: UserPreferences().availableCurrencies, existingPairs: self.viewModel.pairs()) { pair in
            os_log(.info, log: Log.general, "New pair %{public}", pair.description)
        }
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.didLoadView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addCurrencyFlow.run(on: self)
        }
    }

    private func bind() {
        viewModel.rates.observe(on: .main) { rates in
            os_log(.info, log: Log.general, "Rates: %{public}@", rates.description)
        }.disposed(by: viewModel.disposeBag)
        viewModel.error.observe(on: .main) { error in
            guard let error = error else { return }
            os_log(.error, log: Log.general, "Got error %@", error.localizedDescription)
        }.disposed(by: viewModel.disposeBag)
    }
}
