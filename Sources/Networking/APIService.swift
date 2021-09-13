//
//  Service.swift
//  Service
//
//  Created by Artur Rymarz on 09/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: Any]

struct APIService: Service {
    let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func call<T: Endpoint>(_ endpoint: T, completion: @escaping (Result<T.Response, ServiceError>) -> Void) {
        var request = URLRequest(url: configuration.apiUrl ?? Constants.apiUrl)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        switch endpoint.method {
        case .post:
            do {
                request.httpBody = try endpoint.encodedBody()
            } catch {
                completion(.failure(.incorrectRequestBody))
                return
            }
        default:
            break
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestError(error: error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                completion(.failure(.unauthorized))
            }

            guard let decoded = try? endpoint.decode(data: data) else {
                completion(.failure(.failedToDecode))
                return
            }

            completion(.success(decoded))
        }.resume()
    }
}
