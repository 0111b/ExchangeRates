//
//  ExchangeRateServiceTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 14/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates
//swiftlint:disable force_try

class ExchangeRateServiceTests: XCTestCase {
    
    var fetcher: MockDataFetcher!
    var service: ExchangeRateService!

    override func setUp() {
        super.setUp()
        fetcher = MockDataFetcher()
        service = ExchangeRateService(config: Config(), fetcher: fetcher)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testURLRequest() {
        let pair1 = try! CurrencyPair(rawValue: "USDRUB")
        let pair2 = try! CurrencyPair(rawValue: "RUBUSD")
        fetcher.data = Data()
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: [pair1, pair2]) { _ in
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertTrue(fetcher.requestWasCalled)
        XCTAssertEqual(fetcher.request.url?.host, Config().apiBaseURL.host)
        XCTAssertEqual(fetcher.request.url?.path, "/revolut-ios")
        XCTAssertEqual(fetcher.request.url?.query, "pairs=USDRUB&pairs=RUBUSD")
    }
    
    func testEmptyPairs() {
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: []) { result in
            guard case .success(let rates) = result
                else { return XCTFail("Invalid response") }
            XCTAssertTrue(rates.isEmpty)
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertFalse(fetcher.requestWasCalled)
    }
    
    func testEmptyResponse() {
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        fetcher.data = Data()
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: [pair]) { result in
            guard case .failure(let error) = result,
                case .parsingError = error
                else { return XCTFail("Invalid error") }
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertTrue(fetcher.requestWasCalled)
    }
    
    func testInvalidResponse() {
        let pair = try! CurrencyPair(rawValue: "USDRUB")
        let response = "Response"
        fetcher.data(from: response)
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: [pair]) { result in
            guard case .failure(let error) = result,
                case .parsingError = error
                else { return XCTFail("Invalid error") }
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertTrue(fetcher.requestWasCalled)
    }
    
    func testResponseOrder() {
        let pair1 = try! CurrencyPair(rawValue: "USDRUB")
        let pair2 = try! CurrencyPair(rawValue: "RUBUSD")
        let pairs = [pair1, pair2]
        let response: [String: ExchangeRate.Rate] = ["RUBUSD": 0.34, "USDRUB": 23]
        fetcher.data(from: response)
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: pairs) { result in
            guard case .success(let rates) = result
                else { return XCTFail("Invalid response") }
            XCTAssertEqual(rates.count, pairs.count)
            zip(pairs, rates).forEach { pair, rate in
                XCTAssertEqual(pair, rate.currencies)
            }
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertTrue(fetcher.requestWasCalled)
    }
    
    func testResponseFiltering() {
        let pair1 = try! CurrencyPair(rawValue: "USDRUB")
        let pair2 = try! CurrencyPair(rawValue: "RUBUSD")
        let pairs = [pair1, pair2]
        let response: [String: ExchangeRate.Rate] = ["RUBUSD": 0.34, "CZKGBP": 23, "USDRUB": 42]
        fetcher.data(from: response)
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: pairs) { result in
            guard case .success(let rates) = result
                else { return XCTFail("Invalid response") }
            XCTAssertEqual(rates.count, pairs.count)
            zip(pairs, rates).forEach { pair, rate in
                XCTAssertEqual(pair, rate.currencies)
            }
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertTrue(fetcher.requestWasCalled)
    }

    
    func testRateValue() {
        let pair1 = try! CurrencyPair(rawValue: "USDRUB")
        let pairs = [pair1]
        let response: [String: ExchangeRate.Rate] = ["USDRUB": 42]
        fetcher.data(from: response)
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: pairs) { result in
            guard case .success(let rates) = result
                else { return XCTFail("Invalid response") }
            XCTAssertEqual(rates[0].rate, 42.0)
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertTrue(fetcher.requestWasCalled)
    }
    
    func testMissingValue() {
        let pair1 = try! CurrencyPair(rawValue: "USDRUB")
        let pairs = [pair1]
        let response: [String: ExchangeRate.Rate] = ["RUBUSD": 42]
        fetcher.data(from: response)
        let completionExpectation = self.expectation(description: "Completion was called")
        _ = service.getRates(for: pairs) { result in
            guard case .success(let rates) = result
                else { return XCTFail("Invalid response") }
            XCTAssertEqual(rates[0].rate, 0)
            completionExpectation.fulfill()
        }
        self.wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertTrue(fetcher.requestWasCalled)
    }
}

private struct Config: NetworkConfig {
    var apiBaseURL: URL { return URL(staticString: "https://apple.com") }
}
