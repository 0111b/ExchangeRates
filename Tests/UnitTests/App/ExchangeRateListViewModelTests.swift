//
//  ExchangeRateListViewModelTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 15/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates
//swiftlint:disable force_try

class ExchangeRateListViewModelTests: XCTestCase {
    fileprivate var selectedPairs: MutableObservable<[CurrencyPair]>!
    fileprivate var service: StubExchangeRateService!
    fileprivate var notificationCenter: NotificationCenter!
    
    override func setUp() {
        super.setUp()
        selectedPairs = MutableObservable(value: [])
        service = StubExchangeRateService()
        notificationCenter = NotificationCenter()
    }
    
    private func viewModel(isTimerEnabled: Bool = true) -> ExchangeRateListViewModel {
        let interval: TimeInterval = isTimerEnabled ? 1 : 0
        return ExchangeRateListViewModel(pairs: selectedPairs,
                                         refreshInterval: interval,
                                         service: service,
                                         notificationCenter: notificationCenter)
    }
    
    private func pairs(_ rawList: [String]) -> [CurrencyPair] {
        return rawList.compactMap { try? CurrencyPair(rawValue: $0) }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testShowStartRates() {
        selectedPairs.value = pairs(["USDRUB", "RUBUSD"])
        let viewModel = self.viewModel()
        let ratesCollector = ObservableCollector(observable: viewModel.rates)
        zip(ratesCollector.last, selectedPairs.value).forEach { rate, pair in
            XCTAssertEqual(rate.currencies, pair)
        }
    }
    
    func testCallRequestOnAppear() {
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        XCTAssertTrue(service.requestWasStarted)
    }
    
    func testRequestCanceledOnEdit() {
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        viewModel.didStartEditingList()
        XCTAssertTrue(service.requestWasCanceled)
    }
    
    func testRequestContinueAfterStopEdit() {
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        viewModel.didStartEditingList()
        viewModel.didStopEditingList()
        XCTAssertTrue(service.requestCallCount > 1)
    }
    
    func testRepeatedRequest() {
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        let delay = self.expectation(description: "Test Delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            delay.fulfill()
        }
        self.wait(for: [delay], timeout: 4)
        XCTAssertTrue(service.requestCallCount > 2)
    }
    
    func testResponseUpdatesView() {
        let rates = self.pairs(["USDRUB", "RUBUSD"])
                        .map { ExchangeRate(rate: Double.random(in: 0..<5), currencies: $0) }
        service.response = .success(rates)
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        let ratesCollector = ObservableCollector(observable: viewModel.rates)
        XCTAssertEqual(viewModel.rates.value, ratesCollector.last)
    }
    
    func testNoErrorOnSuccessResponse() {
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        XCTAssertNil(viewModel.error.value)
    }
    
    func testErrorOnFailedResponse() {
        service.response = .failure(.invalidRequest)
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        XCTAssertNotNil(viewModel.error.value)
    }
    
    func testModificationTriggerRefresh() {
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        let viewModel = self.viewModel()
        viewModel.add(pair: pair)
        XCTAssertTrue(service.requestWasStarted)
    }
    
    func testAddItemDisplayedOnUI() {
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        let rate = ExchangeRate(rate: Double.random(in: 0..<1), currencies: pair)
        service.response = .success([rate])
        let viewModel = self.viewModel()
        let ratesCollector = ObservableCollector(observable: viewModel.rates)
        viewModel.add(pair: pair)
        XCTAssertEqual(ratesCollector.last.first?.currencies, pair)
    }
    
    func testAddItemModifiesModel() {
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        let viewModel = self.viewModel()
        viewModel.add(pair: pair)
        XCTAssertEqual(selectedPairs.value, [pair])
    }
    
    func testDeleteItemModifiesModel() {
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        selectedPairs.value = [pair]
        let viewModel = self.viewModel()
        viewModel.removePair(at: 0)
        XCTAssertTrue(selectedPairs.value.isEmpty)
    }
    
    func testDeleteItemDisplayedOnUI() {
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        selectedPairs.value = [pair]
        let viewModel = self.viewModel()
        let ratesCollector = ObservableCollector(observable: viewModel.rates)
        viewModel.removePair(at: 0)
        XCTAssertTrue(ratesCollector.last.isEmpty)
    }
    
    func testMoveItemModifiesModel() {
        let startPairs = self.pairs(["USDRUB", "RUBUSD", "USDGBP"])
        let endPairs = self.pairs(["USDGBP", "RUBUSD", "USDRUB"])
        self.selectedPairs.value = startPairs
        let viewModel = self.viewModel()
        viewModel.movePair(from: 2, to: 0)
        XCTAssertEqual(self.selectedPairs.value, endPairs)
    }
    
    func testMoveItemDisplayedOnUI() {
        let startPairs = self.pairs(["USDRUB", "RUBUSD", "USDGBP"])
        self.selectedPairs.value = startPairs
        var rates = startPairs.map { ExchangeRate(rate: Double.random(in: 0..<3), currencies: $0) }
        rates.swapAt(2, 0)
        service.response = .success(rates)
        let viewModel = self.viewModel()
        let ratesCollector = ObservableCollector(observable: viewModel.rates)
        viewModel.movePair(from: 2, to: 0)
        XCTAssertEqual(ratesCollector.last, rates)
    }
    
    func testBecomeActiveNotification() {
        let viewModel = self.viewModel()
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        XCTAssertTrue(service.requestWasStarted)
        XCTAssertTrue(viewModel.isTimerStarted)
    }
    
    func testResignActiveNotification() {
        let viewModel = self.viewModel()
        viewModel.viewWillAppear()
        notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)
        XCTAssertFalse(viewModel.isTimerStarted)
    }
}

private class StubExchangeRateService: ExchangeRateServiceProtocol {
    var requestWasStarted = false
    var requestWasCanceled = false
    var requestCallCount: UInt = 0
    
    var response: Result<[ExchangeRate], DataFetchError>?

    func getRates(for pairs: [CurrencyPair], completion: @escaping (Result<[ExchangeRate], DataFetchError>) -> Void) -> Disposable {
        requestWasStarted = true
        requestCallCount += 1
        completion(response ?? .success([]))
        return Disposable { [unowned self] in
            self.requestWasCanceled = true
        }
    }
}
