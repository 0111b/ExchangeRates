//
//  ListDatasource.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 09/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit

class ListDatasource<Item, Cell>: NSObject, UITableViewDataSource
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

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }

    private let configurator: CellConfigurator
    fileprivate unowned let tableView: UITableView
    fileprivate var items = [Item]()
}

extension ListDatasource where Cell: ConfigurableCell, Cell.Model == Item {
    convenience init(_ tableView: UITableView) {
        self.init(tableView) { cell, item in
            cell.set(model: item)
        }
    }
}

class AnimatableListDatasource<Item, Cell>: ListDatasource<Item, Cell>
where Item: Equatable, Cell: NibReusableTableViewCell {

    var updateAnimation: UITableView.RowAnimation = .fade

    override func set(items: [Item]) {
        let update = difference(from: self.items, to: items)
        let insertIndexPaths = update.inserts.map { IndexPath(row: $0, section: 0) }
        let deleteIndexPaths = update.deletions.map { IndexPath(row: $0, section: 0) }
        self.items = items
        tableView.beginUpdates()
        tableView.insertRows(at: insertIndexPaths, with: updateAnimation)
        tableView.deleteRows(at: deleteIndexPaths, with: updateAnimation)
        tableView.endUpdates()
    }

    /// Solve LCS problem
    ///
    /// Use `difference(from:)` in Swift 5.1
    ///
    /// TODO: optimize implementation
    private func difference(from original: [Item], to items: [Item]) -> Updates {
        let insertedObjects = items.filter { !original.contains($0) }
        let insertedIndexes = insertedObjects.compactMap { items.firstIndex(of: $0) }
        let deletedObjects = original.filter { !items.contains($0) }
        let deletedIndexes = deletedObjects.compactMap { original.firstIndex(of: $0) }
        return Updates(inserts: insertedIndexes, deletions: deletedIndexes)
    }

    private struct Updates {
        let inserts: [Int]
        let deletions: [Int]
    }

}
