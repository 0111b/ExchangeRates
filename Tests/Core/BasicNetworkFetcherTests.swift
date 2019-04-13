//
//  BasicNetworkFetcherTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 13/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates

class BasicNetworkFetcherTests: XCTestCase {
    
    private var session: URLSessionStub!
    private var fetcher: BasicNetworkFetcher!

    override func setUp() {
        super.setUp()
        session = URLSessionStub()
        fetcher = BasicNetworkFetcher(session: session, completionQueue: .main)
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testRequestPassed() {
        let request = URLRequest(url: URL(staticString: "https://apple.com"))
        _ = execute(request: request)
        XCTAssertEqual(session.request, request)
    }
    
    func testTaskStarted() {
        _ = execute()
        XCTAssertTrue(session.task.wasStarted)
    }
    
    func testTaskCanceled() {
        let bag = DisposeBag()
        self.execute().disposed(by: bag)
        XCTAssertFalse(self.session.task.wasCanceled)
        bag.dispose()
        XCTAssertTrue(session.task.wasCanceled)
    }
    
    func testDecodeCalled() {
        let decodeExpectation = self.expectation(description: "Decode was called")
        let responseData = Data()
        session.data = responseData
        let decode: (Data) throws -> Void = { decodeData in
            XCTAssertEqual(responseData, decodeData)
            decodeExpectation.fulfill()
        }
        _ = execute(decode: decode)
        self.wait(for: [decodeExpectation], timeout: 1)
    }
    
    func testCompletionCalled() {
        let completionExpectation = self.expectation(description: "Completion was called")
        let completion: (Result<Void, DataFetchError>) -> Void = { _ in
            completionExpectation.fulfill()
        }
        _ = execute(completion: completion)
        self.wait(for: [completionExpectation], timeout: 1)
    }
    
    func testInvalidStatusCode() {
        session.response = makeResponse(statusCode: 404)
        let completionExpectation = self.expectation(description: "Completion was called")
        let completion: (Result<Void, DataFetchError>) -> Void = { [unowned self] result in
            guard case .failure(let error) = result,
                case .invalidResponse(let response) = error
                else { return XCTFail("Invalid error") }
            XCTAssertEqual(self.session.response, response)
            completionExpectation.fulfill()
        }
        _ = execute(completion: completion)
        self.wait(for: [completionExpectation], timeout: 1)
    }
    
    func testTransportError() {
        class NetworkError: Error {}
        session.error = NetworkError()
        let completionExpectation = self.expectation(description: "Completion was called")
        let completion: (Result<Void, DataFetchError>) -> Void = { result in
            guard case .failure(let error) = result,
                case .networkError(let networkError) = error
                else { return XCTFail("Invalid error") }
            XCTAssertTrue(networkError is NetworkError)
            completionExpectation.fulfill()
        }
        _ = execute(completion: completion)
        self.wait(for: [completionExpectation], timeout: 1)
    }
    
    func testParsingError() {
        class ParsingError: Error {}
        let decodeExpectation = self.expectation(description: "Decode was called")
        session.data = Data()
        let decode: (Data) throws -> Void = { decodeData in
            decodeExpectation.fulfill()
            throw ParsingError()
        }
        let completionExpectation = self.expectation(description: "Completion was called")
        let completion: (Result<Void, DataFetchError>) -> Void = { result in
            guard case .failure(let error) = result,
                case .parsingError(let networkError) = error
                else { return XCTFail("Invalid error") }
            XCTAssertTrue(networkError is ParsingError)
            completionExpectation.fulfill()
        }
        _ = execute(decode: decode, completion: completion)
        self.wait(for: [decodeExpectation, completionExpectation], timeout: 1)

    }
    
    private func execute(request: URLRequest = URLRequest(url: URL(staticString: "https://google.com")),
                         decode: @escaping (Data) throws -> Void = { _ in },
                         completion: @escaping (Result<Void, DataFetchError>) -> Void = { _ in }
        ) -> Disposable {
        return fetcher.execute(request: request, decode: decode, completion: completion)
    }

}

func makeResponse(statusCode: Int) -> URLResponse? {
    return HTTPURLResponse(url: URL(staticString: "https://google.com"), statusCode: 200, httpVersion: nil, headerFields: [:])
}

private class URLSessionDataTaskStub: URLSessionDataTaskProtocol {
    var wasStarted = false
    func resume() {
        wasStarted = true
    }
    
    var wasCanceled = false
    func cancel() {
        wasCanceled = true
    }
    
}

private class URLSessionStub: URLSessionProtocol {
    var data: Data?
    var response: URLResponse? = makeResponse(statusCode: 200)
    var error: Error?
    
    var request: URLRequest!
    var task: URLSessionDataTaskStub!
    
    func makeDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        self.request = request
        self.task = URLSessionDataTaskStub()
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            completionHandler(self.data, self.response, self.error)
        }
        return task
    }
}
