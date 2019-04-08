//
//  ReusableCell.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

protocol ReusableCell: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol NibReusableCell: ReusableCell {
    static var nib: UINib { get }
}

extension NibReusableCell {
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: Bundle.main)
    }
}

typealias ReusableTableViewCell = UITableViewCell & ReusableCell
typealias NibReusableTableViewCell = UITableViewCell & NibReusableCell

extension UITableView {
    func register<Cell: NibReusableTableViewCell>(cell: Cell.Type) {
        self.register(Cell.nib, forCellReuseIdentifier: Cell.reuseIdentifier)
    }

    func dequeueReusableCell<Cell: ReusableTableViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Wrong cell type at: \(indexPath). Waiting for \(Cell.self)")
        }
        return cell
    }
}
