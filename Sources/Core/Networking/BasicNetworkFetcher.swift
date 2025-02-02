//
//  BasicNetworkFetcher.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation
import os.log
import os.signpost

final class BasicNetworkFetcher: NetworkDataFetcher {

    convenience init(configuration: URLSessionConfiguration = .default,
                     completionQueue: DispatchQueue = .main) {
        self.init(session: URLSession(configuration: configuration), completionQueue: completionQueue)
    }
    
    init(session: URLSessionProtocol,
         completionQueue: DispatchQueue = .main) {
        self.session = session
        self.completionQueue = completionQueue
    }

    private let session: URLSessionProtocol
    private lazy var processingQueue = DispatchQueue(label: "com.revolut.BasicNetworkFetcher.processing",
                                                     qos: .userInitiated,
                                                     attributes: .concurrent)
    private let completionQueue: DispatchQueue

    @discardableResult
    func execute<FetchResult>(request: URLRequest,
                              decode: @escaping (Data) throws -> FetchResult,
                              completion: @escaping (Result<FetchResult, DataFetchError>) -> Void) -> Disposable {
        let signpostId = OSSignpostID(log: Log.networking, object: request as AnyObject)
        let completionQueue = self.completionQueue
        let done: (Result<FetchResult, DataFetchError>) -> Void = { result in
            completionQueue.async { completion(result) }
        }
        let fail: (DataFetchError) -> Void = { done(.failure($0)) }
        let requestCompletion: (Data?, URLResponse?, Error?) -> Void = { [processingQueue = self.processingQueue] data, urlResponse, error in
            os_signpost(.end, log: Log.networking, name: "Execute request", signpostID: signpostId, "Finish request")
            if let error = error {
                fail(.networkError(error))
                return
            }
            guard let httpResponse = urlResponse as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode,
                let data = data
                else {
                    fail(.invalidResponse(urlResponse))
                    return
            }
            processingQueue.async {
                os_signpost(.begin, log: Log.networking, name: "Parse request", signpostID: signpostId, "Begin processing")
                let result: Result<FetchResult, DataFetchError>
                let isSuccess: Bool
                do {
                    result = try .success(decode(data))
                    isSuccess = true
                } catch let error {
                    result = .failure(.parsingError(error))
                    isSuccess = false
                }
                os_signpost(.end, log: Log.networking, name: "Parse request", signpostID: signpostId, "Finished processing %d", isSuccess)
                done(result)
            }
        }
        let task = session.makeDataTask(with: request, completionHandler: requestCompletion)
        os_signpost(.begin, log: Log.networking, name: "Execute request", signpostID: signpostId, "Start request")
        os_log(.debug, log: Log.networking, "Request URL: %@", request.url?.absoluteString ?? "")
        task.resume()
        return Disposable {
            task.cancel()
        }
    }
}

protocol URLSessionProtocol {
    func makeDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

extension URLSession: URLSessionProtocol {
    func makeDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return self.dataTask(with: request, completionHandler: completionHandler)
    }
}
extension URLSessionDataTask: URLSessionDataTaskProtocol {}
