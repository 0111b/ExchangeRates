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
         refreshInterval: TimeInterval,
         service: ExchangeRateServiceProtocol = ExchangeRateService(config: ApplicationConfig.current),
         notificationCenter: NotificationCenter = .default) {
        self.selectedPairs = pairs
        self.refreshInterval = refreshInterval
        self.service = service
        let rates = pairs.value.map { ExchangeRate(rate: 0.0, currencies: $0) }
        ratesRelay = MutableObservable(value: rates)
        pairs.observe(skipCurrent: true) { [unowned self] _ in
            self.fetchRates()
        }.disposed(by: disposeBag)
        registerForSystemNotifications(with: notificationCenter)
    }

    let disposeBag = DisposeBag()

    // MARK: - Output -

    private let ratesRelay: MutableObservable<[ExchangeRate]>
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
        func update<Value>(_ list: inout [Value], item: Value) {
            list.insert(item, at: 0)
        }
        update(&ratesRelay.value, item: ExchangeRate(rate: 0.0, currencies: pair))
        update(&selectedPairs.value, item: pair)
    }

    func removePair(at index: Int) {
        func update<Value>(_ list: inout [Value]) {
            list.remove(at: index)
        }
        update(&ratesRelay.value)
        update(&selectedPairs.value)
    }

    func movePair(from source: Int, to destination: Int) {
        func update<Value>(_ list: inout [Value]) {
            list.swapAt(source, destination)
        }
        update(&ratesRelay.value)
        update(&selectedPairs.value)
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
        register(UIApplication.willResignActiveNotification) { [unowned self] in self.stopTimer() }
        register(UIApplication.didBecomeActiveNotification) { [unowned self] in self.startTimer() }
    }

    // MARK: Timer
    private let refreshInterval: TimeInterval
    private var refreshTimer = Disposable.empty
    
    var isTimerStarted: Bool { return !refreshTimer.isEmpty }

    private func startTimer() {
        guard !isTimerStarted // not started
            && refreshInterval > 0 // correct interval
            else { return }
        os_log(.info, log: Log.general, "Start refresh timer")
        refreshTimer = Timer.schedule(interval: refreshInterval).observe(on: .main) { [unowned self] in
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
                self?.errorRelay.value = nil
            case .failure(let error):
                self?.errorRelay.value = error
            }
        }
    }
}
