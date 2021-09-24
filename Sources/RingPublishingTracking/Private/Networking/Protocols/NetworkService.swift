//
//  NetworkService.swift
//  NetworkService
//
//  Created by Artur Rymarz on 15/09/2021.
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
