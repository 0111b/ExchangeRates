//
//  ExchangeRateListViewController.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

final class ExchangeRateListViewController: UIViewController {
    private let viewModel = ExchangeRateListViewModel()
    private lazy var addCurrencyFlow: AddCurrencyPairFlow = {
        return AddCurrencyPairFlow(currencies: UserPreferences().availableCurrencies) { pair in
            print(pair)
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
            print(rates)
        }.disposed(by: viewModel.disposeBag)
        viewModel.error.observe(on: .main) { error in
            guard let error = error else { return }
            print(error)
        }.disposed(by: viewModel.disposeBag)
    }
}
