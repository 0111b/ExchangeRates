//
//  CurrencySelectorViewController.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

final class CurrencySelectorViewController: UITableViewController {
    init(currencies: [Currency], disabled: Set<Currency.Code>) {
        self.currencies = currencies
        disabledCodes = disabled
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var didSelectItem: (Currency) -> Void = { _ in }

    private let currencies: [Currency]
    private let disabledCodes: Set<Currency.Code>

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        tableView.register(cell: CurrencySelectorCell.self)
        setupAccessibility()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = currency(at: indexPath)
        let cell: CurrencySelectorCell = tableView.dequeueReusableCell(for: indexPath)
        cell.set(currency: item, enabled: canSelect(item))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = currency(at: indexPath)
        let canSelect = self.canSelect(item)
        tableView.deselectRow(at: indexPath, animated: canSelect)
        if canSelect {
            didSelectItem(item)
        }
    }

    private func currency(at indexPath: IndexPath) -> Currency {
        assert(currencies.indices ~= indexPath.row)
        return currencies[indexPath.row]
    }

    private func canSelect(_ item: Currency) -> Bool {
        return !disabledCodes.contains(item.code)
    }
    
    private func setupAccessibility() {
        tableView.accessibilityIdentifier = "CurrencySelectorScreen"
    }
}
