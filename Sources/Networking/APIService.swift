//
//  Service.swift
//  Service
//
//  Created by Artur Rymarz on 09/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol NetworkSession {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: NetworkSession {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: request, completionHandler: completionHandler).resume()
    }
}

struct APIService: Service {
    let configuration: Configuration
    let session: NetworkSession

    init(configuration: Configuration, session: NetworkSession = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }

    func call<T: Endpoint>(_ endpoint: T, completion: @escaping (Result<T.Response, ServiceError>) -> Void) {
        guard let path = endpoint.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(.failure(.invalidUrl))
            return
        }

        let urlString = (configuration.apiUrl ?? Constants.apiUrl).appendingPathComponent(path).absoluteString
        guard var urlComponents = URLComponents(string: urlString) else {
            completion(.failure(.invalidUrl))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "_key", value: configuration.apiKey)
        ]

        guard let url = urlComponents.url else {
            completion(.failure(.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
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

        session.dataTask(with: request) { data, response, error in
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
        }
    }
}
