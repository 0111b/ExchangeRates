//
//  ExchangeRateListViewModel.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

final class ExchangeRateListViewModel {

    let disposeBag = DisposeBag()

    private let ratesRelay = MutableObservable<[ExchangeRate]>(value: [])
    var rates: Observable<[ExchangeRate]> { return ratesRelay.asObservable() }

}
