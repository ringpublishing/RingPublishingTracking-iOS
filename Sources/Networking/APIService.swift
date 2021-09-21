//
//  Service.swift
//  Service
//
//  Created by Artur Rymarz on 09/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct APIService: Service {

    let apiUrl: URL
    let apiKey: String
    let session: NetworkSession

    // MARK: Init

    init(apiUrl: URL?, apiKey: String, session: NetworkSession = URLSession.shared) {
        self.apiUrl = apiUrl ?? Constants.apiUrl
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: Methods

    func call<T: Endpoint>(_ endpoint: T, completion: @escaping (Result<T.Response, ServiceError>) -> Void) {
        guard let path = endpoint.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(.failure(.invalidUrl))
            return
        }

        let urlString = apiUrl.appendingPathComponent(path).absoluteString
        guard var urlComponents = URLComponents(string: urlString) else {
            completion(.failure(.invalidUrl))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "_key", value: apiKey)
        ]

        guard let url = urlComponents.url else {
            completion(.failure(.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        do {
            try request.withBody(for: endpoint)
        } catch {
            completion(.failure(.incorrectRequestBody))
            return
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

            #if DEBUG
            let dataString = String(data: data, encoding: .utf8) ?? "Unknown data"
            Logger.log("RESPONSE:\n\(dataString)", level: .debug)
            #endif

            guard let decoded = try? endpoint.decode(data: data) else {
                completion(.failure(.failedToDecode))
                return
            }

            completion(.success(decoded))
        }
    }
}

extension URLRequest {
    mutating func withBody<T: Endpoint>(for endpoint: T) throws {
        switch endpoint.method {
        case .post:
            do {
                #if DEBUG
                if let data = try? endpoint.encodedBody() {
                    let dataString = String(data: data, encoding: .utf8) ?? "Unknown data"
                    Logger.log("REQUEST BODY:\n\(dataString)", level: .debug)
                }
                #endif

                httpBody = try endpoint.encodedBody()
            } catch {
                throw ServiceError.incorrectRequestBody
            }
        default:
            break
        }
    }
}
