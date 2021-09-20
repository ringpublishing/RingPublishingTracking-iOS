//
//  SendEventEndpoint.swift
//  SendEventEndpoint
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct SendEventEnpoint: Endpoint {

    let path: String = Constants.apiVersion
    let method: HTTPMethod = .post
    let body: EventRequest

    func encodedBody() throws -> Data? {
        try body.toBodyData()
    }

    func decode(data: Data) throws -> EventResponse? {
        try JSONDecoder().decode(EventResponse.self, from: data)
    }
}
