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

    let disposeBag = DisposeBag()
    var service: ExchangeRateServiceProtocol
    private var refreshDisposable = Disposable.empty

    private let ratesRelay = MutableObservable<[ExchangeRate]>(value: [])
    var rates: Observable<[ExchangeRate]> { return ratesRelay.asObservable() }
    private let errorRelay = MutableObservable<DataFetchError?>(value: nil)
    var error: Observable<DataFetchError?> { return errorRelay.asObservable() }

    func didLoadView() {
        do {
            let usd = try CurrencyFactory.make(from: "USD")
            let gbp = try CurrencyFactory.make(from: "GBP")
            let pairs = [
                CurrencyPair(first: usd, second: gbp),
                CurrencyPair(first: gbp, second: usd)
            ]
            refreshDisposable = service.getRates(for: pairs) { [weak self] result in
                switch result {
                case .success(let rates):
                    self?.ratesRelay.value = rates
                case .failure(let error):
                    self?.errorRelay.value = error
                }
            }
        } catch {
            print(error)
        }
    }

}
