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

    override func loadView() {
        self.view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "AddCurrencyPair"), style: .plain, target: self, action: #selector(type(of: self).addButtonTapped(sender:)))
        tableView.delegate = self
        tableView.dataSource = dataSource
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDIssapear()
    }

    // MARK: - Private -

    private unowned let coordinator: ExchangeRateListCoordinator
    private let viewModel: ExchangeRateListViewModel
    private lazy var dataSource: ListDatasource<ExchangeRate, ExchangeRateListCell> = .init(self.tableView) { cell, rate in

    }

    private func bind() {
        viewModel.rates.observe(on: .main) { [unowned dataSource = self.dataSource] rates in
            os_log(.info, log: Log.general, "Rates: %{public}@", rates.description)
            dataSource.set(items: rates)
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

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        return table
    }()
}

extension ExchangeRateListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

private class ListDatasource<Item, Cell>: NSObject, UITableViewDataSource
where Cell: NibReusableTableViewCell {
    typealias CellConfigurator = (Cell, Item) -> Void

    init(_ tableView: UITableView, configure: @escaping CellConfigurator) {
        self.tableView = tableView
        configurator = configure
        tableView.register(cell: Cell.self)
    }

    func set(items: [Item]) {
        self.items = items
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(for: indexPath)
        configurator(cell, item(at: indexPath))
        return cell
    }

    func item(at indexPath: IndexPath) -> Item {
        assert(items.indices ~= indexPath.row)
        return items[indexPath.row]
    }

    private let configurator: CellConfigurator
    private unowned let tableView: UITableView
    private var items = [Item]()
}
