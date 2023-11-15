//
//  URLSessionMock.swift
//  URLSessionMock
//
//  Created by Artur Rymarz on 15/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

class NetworkSessionMock: NetworkSession {

    var data: Data?
    var error: Error?
    var response: URLResponse?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        completionHandler(data, response, error)
    }
}
