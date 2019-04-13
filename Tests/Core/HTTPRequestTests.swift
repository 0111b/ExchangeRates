//
//  HTTPRequestTests.swift
//  ExchangeRatesTests
//
//  Created by Alexandr Goncharov on 13/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import XCTest
@testable import ExchangeRates
//swiftlint:disable force_unwrapping

class HTTPRequestTests: XCTestCase {
    
    var baseURL: URL!

    override func setUp() {
        super.setUp()
        baseURL = URL(staticString: "https://google.com")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPath() {
        let paths: [(input: String, output: String)] = [
            ("foo", "/foo"),
            ("foo/bar", "/foo/bar"),
            ("/foo", "/foo"),
            ("foo?bar", "/foo?bar")
        ]
        for path in paths {
            let request: URLRequest! = HTTPRequest(path: path.input).buildRequest(against: baseURL)
            XCTAssertNotNil(request, "Cant build request")
            XCTAssertEqual(request.url!.path, path.output)
        }
    }
    
    func testHttpMethod() {
        let methods: [String: HTTPRequest.Method] = [
            "GET": .get,
            "POST": .post,
            "PUT": .put
        ]
        methods.forEach { raw, method in
            let request: URLRequest! = HTTPRequest(path: "foo", method: method).buildRequest(against: baseURL)
            XCTAssertNotNil(request, "Cant build request")
            XCTAssertEqual(request.httpMethod, raw)
        }
    }
    
    func testHeaders() {
        let headers: HTTPRequest.Headers = ["Foo": "Bar"]
        let request: URLRequest! = HTTPRequest(path: "foo", headers: headers).buildRequest(against: baseURL)
        XCTAssertNotNil(request, "Cant build request")
        XCTAssertEqual(request.allHTTPHeaderFields, headers)
    }
    
    func testQuery() {
        let items = [
            URLQueryItem(name: "Foo", value: "Bar"),
            URLQueryItem(name: "Baz", value: nil)
        ]
        let url: URL! = HTTPRequest(path: "path", query: items).buildRequest(against: baseURL)?.url
        XCTAssertNotNil(url)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(components)
        XCTAssertEqual(components?.queryItems, items)
    }
}
