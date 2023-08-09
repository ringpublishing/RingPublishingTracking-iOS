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

    // MARK: Methods

    /// Makes a network request with the given endpoint providing a response in the completion closure.
    func call<T: Endpoint>(_ endpoint: T, completion: @escaping (Result<T.Response, ServiceError>) -> Void) {
        Logger.log(endpoint.endpointDescription)

        guard let url = try? buildUrl(for: endpoint) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        do {
            try request.withBody(for: endpoint)
        } catch {
            Logger.log("Cannot encode request body: \(request.description)", level: .error)
            completion(.failure(.genericError))
            return
        }

        session.dataTask(with: request) { data, response, responseError in
            if let error = responseError {
                Logger.log("Received response with error: \(error.localizedDescription)", level: .error)
                completion(.failure(.requestError(error: error)))
                return
            }

            if let serviceError = response?.serviceError {
                Logger.log("Received unexpected response status code: \(serviceError)", level: .error)
                completion(.failure(serviceError))
                return
            }

            guard let data = data else {
                Logger.log("Request data was not present.", level: .error)
                completion(.failure(.genericError))
                return
            }

            do {
                let decoded = try endpoint.decode(data: data)

                Logger.log("Received response: \(decoded)")
                completion(.success(decoded))

            } catch {
                Logger.log("Could not decode received data", level: .error)
                completion(.failure(.decodingError(error: error)))
            }
        }
    }

    private func buildUrl<T: Endpoint>(for endpoint: T) throws -> URL {
        guard let path = endpoint.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            Logger.log("Cannot send request. Path is invalid: \(endpoint.path)", level: .error)
            throw ServiceError.genericError
        }

        let urlString = apiUrl.appendingPathComponent(path).absoluteString
        guard var urlComponents = URLComponents(string: urlString) else {
            Logger.log("Cannot send request. URL is invalid: \(urlString)", level: .error)
            throw ServiceError.genericError
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "_key", value: apiKey)
        ]

        guard let url = urlComponents.url else {
            Logger.log("Cannot send request. URL components are invalid: \(urlComponents)", level: .error)
            throw ServiceError.genericError
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
                throw ServiceError.genericError
            }
        default:
            break
        }
    }
}

extension URLResponse {

    /// Map status code to `ServiceError`
    var serviceError: ServiceError? {
        guard let response = self as? HTTPURLResponse, !(200...299).contains(response.statusCode) else { return nil }

        Logger.log("Received server response with unacceptable status code: \(response.statusCode)", level: .error)
        return ServiceError.responseError(statusCode: response.statusCode)
    }
}
