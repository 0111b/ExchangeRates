//
//  Disposable.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

final class Disposable {

    init(_ dispose: @escaping () -> Void) {
        self.dispose = dispose
        isEmpty = false
    }

    let isEmpty: Bool

    class var empty: Disposable { return Disposable() }

    func disposed(by bag: DisposeBag) {
        bag.insert(disposable: self)
    }

    deinit {
        dispose()
    }

    private let dispose: () -> Void

    private init() {
        dispose = { }
        isEmpty = true
    }
}

final class DisposeBag {
    private var disposables = [Disposable]()

    func insert(disposable: Disposable) {
        disposables.append(disposable)
    }

    func dispose() {
        disposables = []
    }
}
