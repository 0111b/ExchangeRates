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
        viewModel.didLoadView()
    }
}
