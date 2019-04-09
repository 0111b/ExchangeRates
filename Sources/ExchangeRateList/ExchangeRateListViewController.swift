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
    init(coordinator: ExchangeRateListCoordinator, viewModel: ExchangeRateListViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private unowned let coordinator: ExchangeRateListCoordinator
    private let viewModel: ExchangeRateListViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "AddCurrencyPair"), style: .plain, target: self, action: #selector(type(of: self).addButtonTapped(sender:)))
        bind()
        viewModel.didLoadView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

    @objc private func addButtonTapped(sender: Any) {
        coordinator.addCurrencyPair { [weak viewModel = self.viewModel] newPair in
            viewModel?.add(pair: newPair)
        }
    }
}
