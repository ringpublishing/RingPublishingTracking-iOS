//
//  Service.swift
//  Service
//
//  Created by Artur Rymarz on 09/09/2021.
//

import Foundation

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: Any]

struct APIService: Service {
    init() {

    }

    func call<T: Endpoint>(_ endpoint: T, completion: @escaping (Result<T.Response, ServiceError>) -> Void) {
        var request = URLRequest(url: URL(string: "")!)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
//        request.addHeaders(endpoint.headers)

        switch endpoint.method {
        case .post:
            guard let parameters = endpoint.parameters else {
                return
            }

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

//extension URLRequest {
//    mutating func addHeaders(_ headers: HTTPHeaders?) {
//        headers?.forEach {
//            addValue($0.value, forHTTPHeaderField: $0.key)
//        }
//    }
//}
