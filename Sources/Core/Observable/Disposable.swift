//
//  Disposable.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

final class Disposable {
    private let dispose: () -> Void

    init(_ dispose: @escaping () -> Void) {
        self.dispose = dispose
    }

    deinit {
        dispose()
    }

    func disposed(by bag: DisposeBag) {
        bag.insert(disposable: self)
    }

    class var empty: Disposable { return Disposable { } }
}

final class DisposeBag {
    private var disposables = [Disposable]()

    func insert(disposable: Disposable) {
        disposables.append(disposable)
    }
}
