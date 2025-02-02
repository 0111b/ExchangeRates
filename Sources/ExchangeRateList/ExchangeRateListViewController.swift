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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(type(of: self).didChangeContentSizeCategory(sender:)),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white
        self.view.addSubview(contentView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Localized("ExchangeRateList.Title")
        self.navigationItem.rightBarButtonItem = addBarButtonItem
        setLeftButtonItem(editing: false)
        tableView.delegate = self
        tableView.dataSource = dataSource
        setupConstraints()
        setupAccessibility()
        bind()
        tableView.flashScrollIndicators()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDissapear()
    }

    @objc private func addButtonTapped(sender: UIBarButtonItem) {
        if !dataSource.items.isEmpty {
            tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        setTableView(editing: false)
        coordinator.addCurrencyPair(sender: sender) { [weak viewModel = self.viewModel] newPair in
            viewModel?.add(pair: newPair)
        }
    }

    @objc private func editButtonTapped(sender: Any) {
        setTableView(editing: !tableView.isEditing)
    }

    @objc private func didChangeContentSizeCategory(sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private unowned let coordinator: ExchangeRateListCoordinator
    private let viewModel: ExchangeRateListViewModel
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource(self.tableView)
        dataSource.moveItem = self.viewModel.movePair(from:to:)
        dataSource.removeItem = self.viewModel.removePair(at:)
        return dataSource
    }()
    
    private func bind() {
        viewModel.rates.observe(on: .main) { [unowned self] rates in
            self.didRecieve(rates: rates)
        }.disposed(by: viewModel.disposeBag)
        viewModel.error.observe(on: .main) { [unowned self] error in
            self.didRecieve(error: error)
        }.disposed(by: viewModel.disposeBag)
    }

    private func didRecieve(rates: [ExchangeRate]) {
        os_log(.debug, log: Log.general, "Rates: %{public}@", rates.description)
        dataSource.set(items: rates)
        let isEmpty = rates.isEmpty
        tableView.isHidden = isEmpty
        emptyHintView.isHidden = !isEmpty
        editBarButtonItem.isEnabled = !isEmpty
        doneBarButtonItem.isEnabled = !isEmpty
    }

    private func didRecieve(error: DataFetchError?) {
        let errorMessage: String? = {
            guard let error = error, !error.isNetworkCancel else { return nil }
            let text = error.localizedDescription
            os_log(.error, log: Log.general, "Got error %@", text)
            return text
        }()
        errorView.isHidden = errorMessage == nil
        errorMessage.map {
            errorView.text = Localized(format: "ExchangeRateList.Error.Message", $0)
        }
    }

    private func setTableView(editing isEditing: Bool) {
        if isEditing { errorView.isHidden = true }
        setLeftButtonItem(editing: isEditing)
        guard isEditing != tableView.isEditing else { return }
        tableView.setEditing(isEditing, animated: true)
        if isEditing {
            viewModel.didStartEditingList()
        } else {
            viewModel.didStopEditingList()
        }
    }

    private func setLeftButtonItem(editing isEditing: Bool) {
        self.navigationItem.leftBarButtonItem = isEditing ? doneBarButtonItem : editBarButtonItem
    }

    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let guide = self.view.readableContentGuide
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: contentView.topAnchor),
            guide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            guide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
    }
    
    private func setupAccessibility() {
        view.accessibilityIdentifier = "ExchangeRatesScreen"
        editBarButtonItem.accessibilityIdentifier = "editButton"
        doneBarButtonItem.accessibilityIdentifier = "doneButton"
        addBarButtonItem.accessibilityIdentifier = "addButton"
        errorView.accessibilityIdentifier = "errorView"
        emptyHintView.accessibilityIdentifier = "emptyHintView"
        tableView.accessibilityIdentifier = "ratesList"
    }

    private lazy var contentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.emptyHintView, self.tableView, self.errorView])
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        return table
    }()

    private lazy var errorView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.backgroundColor = .white
        label.textColor = .red
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var emptyHintView: UIView = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = Localized("ExchangeRateList.Empty.Hint")
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(type(of: self).editButtonTapped(sender:)))
    private lazy var doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(type(of: self).editButtonTapped(sender:)))
    private lazy var addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(type(of: self).addButtonTapped(sender:)))
}

extension ExchangeRateListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil // default actions
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        setLeftButtonItem(editing: true)
        viewModel.didStartEditingList()
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        setLeftButtonItem(editing: false)
        viewModel.didStopEditingList()
    }
}

private final class TableDataSource: AnimatableListDatasource<ExchangeRate, ExchangeRateListCell> {

    var moveItem: (Int, Int) -> Void = { _, _ in }
    var removeItem: (Int) -> Void = { _ in }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveItem(sourceIndexPath.row, destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case .delete = editingStyle else { return }
        removeItem(indexPath.row)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
