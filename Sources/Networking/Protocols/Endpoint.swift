//
//  Endpoint.swift
//  Endpoint
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]

protocol Endpoint {

    associatedtype Body = Encodable
    associatedtype Response = Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var body: Body? { get }

    func encodedBody() throws -> Data?
    func decode(data: Data) throws -> Response?
}

extension Endpoint {

    var headers: HTTPHeaders {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": UserAgent.appTrackingUserAgent
        ]
    }

    var body: Void? {
        nil
    }
}
