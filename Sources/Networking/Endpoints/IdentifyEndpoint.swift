//
//  IdentifyEndpoint.swift
//  IdentifyEndpoint
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct IdentifyEnpoint: Endpoint {
    
    let path: String = "\(Constants.apiVersion)/me"
    let method: HTTPMethod = .post
    let body: IdentifyRequest?

    func encodedBody() throws -> Data? {
        guard let body = body else {
            return nil
        }

        return try JSONEncoder().encode(body)
    }

    func decode(data: Data) throws -> IdentifyResponse? {
        try JSONDecoder().decode(IdentifyResponse.self, from: data)
    }
}
