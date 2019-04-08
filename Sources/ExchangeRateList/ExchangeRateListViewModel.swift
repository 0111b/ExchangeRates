//
//  ExchangeRateListViewModel.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

final class ExchangeRateListViewModel {
    init(service: ExchangeRateServiceProtocol = ExchangeRateService(config: ApplicationConfig.current)) {
        self.service = service
    }

    var service: ExchangeRateServiceProtocol
    let disposeBag = DisposeBag()

    private let ratesRelay = MutableObservable<[ExchangeRate]>(value: [])
    var rates: Observable<[ExchangeRate]> { return ratesRelay.asObservable() }

    func didLoadView() {
        do {
            let usd = try CurrencyFactory.make(from: "USD")
            let gbp = try CurrencyFactory.make(from: "GBP")
            let pairs = [
                CurrencyPair(first: usd, second: gbp),
                CurrencyPair(first: gbp, second: usd)
            ]
            service.getRates(for: pairs) { result in
                print(result)
            }
        } catch {
            print(error)
        }
    }

}
