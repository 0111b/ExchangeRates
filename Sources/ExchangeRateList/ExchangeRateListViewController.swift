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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(type(of: self).addButtonTapped(sender:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(type(of: self).editButtonTapped(sender:)))
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
        viewModel.viewDidDissapear()
    }

    @objc func addButtonTapped(sender: Any) {
        setTableView(editing: false)
        coordinator.addCurrencyPair { [weak viewModel = self.viewModel] newPair in
            viewModel?.add(pair: newPair)
        }
    }

    @objc func editButtonTapped(sender: Any) {
        setTableView(editing: !tableView.isEditing)
    }

    // MARK: - Private -

    private unowned let coordinator: ExchangeRateListCoordinator
    private let viewModel: ExchangeRateListViewModel
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource(self.tableView)
        dataSource.moveItem = self.viewModel.movePair(from:to:)
        dataSource.removeItem = self.viewModel.removePair(at:)
        return dataSource
    }()
    
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

    private func setTableView(editing isEditing: Bool) {
        navigationItem.leftBarButtonItem = isEditing ? doneBarButtonItem : editBarButtonItem
        tableView.setEditing(isEditing, animated: true)
        if isEditing {
            viewModel.didStartEditingList()
        } else {
            viewModel.didStopEditingList()
        }
    }

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        return table
    }()

    private lazy var editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(type(of: self).editButtonTapped(sender:)))
    private lazy var doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(type(of: self).editButtonTapped(sender:)))
}

extension ExchangeRateListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

private final class TableDataSource: AnimatableListDatasource<ExchangeRate, ExchangeRateListCell> {

    var moveItem: (Int, Int) -> Void = { _, _ in }
    var removeItem: (Int) -> Void = { _ in }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case .delete = editingStyle else { return }
        removeItem(indexPath.row)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveItem(sourceIndexPath.row, destinationIndexPath.row)
    }
}
