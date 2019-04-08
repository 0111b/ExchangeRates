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

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.didLoadView()
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
