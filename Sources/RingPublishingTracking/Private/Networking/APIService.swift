//
//  Service.swift
//  Service
//
//  Created by Artur Rymarz on 09/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct APIService: Service {

    /// API url
    let apiUrl: URL

    /// API key
    let apiKey: String

    /// Session object used to create requests
    let session: NetworkSession

    // MARK: Init

    /// Initialization for  API service
    /// - Parameters:
    ///   - apiUrl: API url
    ///   - apiKey: API key
    ///   - session: Session object used to create requests. Defaults to `URLSession.shared`
    init(apiUrl: URL, apiKey: String, session: NetworkSession = URLSession.shared) {
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: Methods

    /// Makes a network request with the given endpoint providing a response in the completion closure.
    func call<T: Endpoint>(_ endpoint: T, completion: @escaping (Result<T.Response, ServiceError>) -> Void) {
        Logger.log(endpoint.endpointDescription)

        guard let url = try? buildUrl(for: endpoint) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        do {
            try request.withBody(for: endpoint)
        } catch {
            Logger.log("Cannot encode request body", level: .error)
            completion(.failure(.incorrectRequestBody))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.log("Received response with error: \(error.localizedDescription)", level: .error)
                completion(.failure(.requestError(error: error)))
                return
            }

            guard let data = data else {
                Logger.log("Received response does not contain any data", level: .error)
                completion(.failure(.noData))
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                Logger.log("Given request is forbidden (unauthorized)", level: .error)
                completion(.failure(.unauthorized))
            }

            guard let decoded = try? endpoint.decode(data: data) else {
                completion(.failure(.failedToDecode))
                return
            }

            completion(.success(decoded))
        }
    }

    private func buildUrl<T: Endpoint>(for endpoint: T) throws -> URL {
        guard let path = endpoint.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            Logger.log("Cannot send request. Path is invalid: \(endpoint.path)", level: .error)
            throw ServiceError.invalidUrl
        }

        let urlString = apiUrl.appendingPathComponent(path).absoluteString
        guard var urlComponents = URLComponents(string: urlString) else {
            Logger.log("Cannot send request. URL is invalid: \(urlString)", level: .error)
            throw ServiceError.invalidUrl
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "_key", value: apiKey)
        ]

        guard let url = urlComponents.url else {
            Logger.log("Cannot send request. URL components are invalid: \(urlComponents)", level: .error)
            throw ServiceError.invalidUrl
        }

        return url
    }
}

extension URLRequest {
    /// Fills `URLRequest` body with data from the endpoint
    mutating func withBody<T: Endpoint>(for endpoint: T) throws {
        switch endpoint.method {
        case .post:
            do {
                httpBody = try endpoint.encodedBody()
            } catch {
                throw ServiceError.incorrectRequestBody
            }
        default:
            break
        }
    }
}
