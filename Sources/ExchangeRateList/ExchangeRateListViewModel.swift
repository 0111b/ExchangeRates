//
//  ExchangeRateListViewModel.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 08/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit
import os.log

final class ExchangeRateListViewModel {
    init(pairs: MutableObservable<[CurrencyPair]>,
         service: ExchangeRateServiceProtocol = ExchangeRateService(config: ApplicationConfig.current),
         notificationCenter: NotificationCenter = .default) {
        self.service = service
        self.selectedPairs = pairs
        pairs.observe { [unowned self] _ in
            self.fetchRates()
        }.disposed(by: disposeBag)
        registerForSystemNotifications(with: notificationCenter)
    }

    let disposeBag = DisposeBag()

    // MARK: - Output -

    private let ratesRelay = MutableObservable<[ExchangeRate]>(value: [])
    var rates: Observable<[ExchangeRate]> { return ratesRelay.asObservable() }
    private let errorRelay = MutableObservable<DataFetchError?>(value: nil)
    var error: Observable<DataFetchError?> { return errorRelay.asObservable() }


    // MARK: - Input -

    func viewWillAppear() {
        startTimer()
    }

    func viewDidDissapear() {
        stopTimer()
    }

    func didStartEditingList() {
        stopTimer()
        fetchRequest = Disposable.empty // cancel pending request
    }

    func didStopEditingList() {
        startTimer()
    }

    func add(pair: CurrencyPair) {
        var pairs = selectedPairs.value
        pairs.insert(pair, at: 0)
        selectedPairs.value = pairs
    }

    func removePair(at index: Int) {
        // Update UI
        var rates = ratesRelay.value
        rates.remove(at: index)
        ratesRelay.value = rates
        // Update model
        var pairs = selectedPairs.value
        pairs.remove(at: index)
        selectedPairs.value = pairs
    }

    func movePair(from source: Int, to destination: Int) {
        // Update UI
        var rates = ratesRelay.value
        rates.swapAt(source, destination)
        ratesRelay.value = rates
        // Update model
        var pairs = selectedPairs.value
        pairs.swapAt(source, destination)
        selectedPairs.value = pairs
    }

    // MARK: - Private -

    private let service: ExchangeRateServiceProtocol
    private let selectedPairs: MutableObservable<[CurrencyPair]>

    // MARK: Notifications

    private func registerForSystemNotifications(with notificationCenter: NotificationCenter) {
        let register: (NSNotification.Name, @escaping () -> Void) -> Void = { notification, handler in
            let token = notificationCenter
                .addObserver(forName: notification,
                             object: nil,
                             queue: .current,
                             using: { _ in handler() })
            Disposable {
                notificationCenter.removeObserver(token)
            }.disposed(by: self.disposeBag)
        }
        register(UIApplication.willResignActiveNotification, self.stopTimer)
        register(UIApplication.didBecomeActiveNotification, self.startTimer)
    }

    // MARK: Timer

    private var refreshTimer = Disposable.empty

    private func startTimer() {
        os_log(.info, log: Log.general, "Start refresh timer")
        refreshTimer = Timer.schedule(interval: 1.0).observe(on: .main) { [unowned self] in
            self.fetchRates()
        }
    }

    private func stopTimer() {
        os_log(.info, log: Log.general, "Stop refresh timer")
        refreshTimer = Disposable.empty
    }

    // MARK: Data fetch

    private var fetchRequest = Disposable.empty
    private func fetchRates() {
        fetchRequest = service.getRates(for: selectedPairs.value) { [weak self] result in
            switch result {
            case .success(let rates):
                self?.ratesRelay.value = rates
            case .failure(let error):
                self?.errorRelay.value = error
            }
        }
    }
}
