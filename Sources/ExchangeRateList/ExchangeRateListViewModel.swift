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


    private let ratesRelay = MutableObservable<[ExchangeRate]>(value: [])
    var rates: Observable<[ExchangeRate]> { return ratesRelay.asObservable() }
    private let errorRelay = MutableObservable<DataFetchError?>(value: nil)
    var error: Observable<DataFetchError?> { return errorRelay.asObservable() }

    private var refreshRequest = Disposable.empty
    private var refreshTimer = Disposable.empty

    func didLoadView() {
        startTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [unowned self] in
            self.stopTimer()
        }
    }

    private func startTimer() {
        refreshTimer = Timer.schedule(interval: 1.0).observe(on: .main) { [unowned self] in
            self.refreshRates()
        }
    }

    private func stopTimer() {
        refreshTimer = Disposable.empty
    }

    private func refreshRates() {
        refreshRequest = service.getRates(for: pairs()) { [weak self] result in
            switch result {
            case .success(let rates):
                self?.ratesRelay.value = rates
            case .failure(let error):
                self?.errorRelay.value = error
            }
        }
    }

    private func pairs() -> [CurrencyPair] {
        do {
            let usd = try CurrencyFactory.make(from: "USD")
            let gbp = try CurrencyFactory.make(from: "GBP")
            return [
                CurrencyPair(first: usd, second: gbp),
                CurrencyPair(first: gbp, second: usd)
            ]
        } catch {
            print(error)
            return []
        }
    }
}
