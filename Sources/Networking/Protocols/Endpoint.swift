//
//  Endpoint.swift
//  Endpoint
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]

/// Protocol describing each API method
protocol Endpoint {

    associatedtype Body = Bodable
    associatedtype Response = Decodable

    /// Path
    var path: String { get }

    /// HTTP method
    var method: HTTPMethod { get }

    /// Headers which by default sends Content-Type json and default User-Agent
    var headers: HTTPHeaders { get }

    /// Body data that should be send with the request. Defaults to empty
    var body: Body? { get }

    /// Encodes body object into Data
    /// - Returns: Data
    ///
    func encodedBody() throws -> Data?

    /// Decodes body data from the response into specific object
    /// - Returns: Decoded object
    func decode(data: Data) throws -> Response?
}

extension Endpoint {

    /// Default headers for endpoint
    var headers: HTTPHeaders {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": UserAgent.appTrackingUserAgent
        ]
    }

    /// Default empty body
    var body: Void? {
        nil
    }
}
