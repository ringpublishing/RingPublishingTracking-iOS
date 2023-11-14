//
//  ArtemisEndpoint.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 08.11.23.
//

import Foundation

struct ArtemisEndpoint: Endpoint {

    let path: String = "\(Constants.apiVersion)/user"

    let method: HTTPMethod = .post

    let body: ArtemisRequest?

    func encodedBody() throws -> Data? {
        guard let body else { return nil }
        return try body.toBodyData()
    }

    func decode(data: Data) throws -> ArtemisResponse {
        try JSONDecoder().decode(ArtemisResponse.self, from: data)
    }
}
