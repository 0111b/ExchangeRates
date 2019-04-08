//
//  BasicNetworkFetcher.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import Foundation

final class BasicNetworkFetcher: NetworkDataFetcher {

    init(configuration: URLSessionConfiguration = .default,
         completionQueue: DispatchQueue = .main) {
        session = URLSession(configuration: configuration)
        self.completionQueue = completionQueue
    }

    private let session: URLSession
    private lazy var processingQueue = DispatchQueue(label: "com.revolut.BasicNetworkFetcher.processing",
                                                     qos: .userInitiated,
                                                     attributes: .concurrent)
    private let completionQueue: DispatchQueue

    @discardableResult
    func execute<FetchResult>(request: URLRequest,
                              decode: @escaping (Data) throws -> FetchResult,
                              completion: @escaping (Result<FetchResult, DataFetchError>) -> Void) -> Cancellable {
        let completionQueue = self.completionQueue
        let done: (FetchResult) -> Void = { result in
            completionQueue.async { completion(.success(result)) }
        }
        let fail: (DataFetchError) -> Void = { error in
            completionQueue.async { completion(.failure(error)) }
        }
        let requestCompletion: (Data?, URLResponse?, Error?) -> Void = { [processingQueue = self.processingQueue] data, urlResponse, error in
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
                do {
                    let result = try decode(data)
                    done(result)
                } catch let error {
                    fail(.parsingError(error))
                }
            }
        }
        let task = session.dataTask(with: request, completionHandler: requestCompletion)
        task.resume()
        return task
    }
}

extension URLSessionDataTask: Cancellable {}
