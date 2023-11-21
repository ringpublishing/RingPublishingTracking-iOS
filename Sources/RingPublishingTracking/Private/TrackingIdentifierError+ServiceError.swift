//
//  TrackingIdentifierError+ServiceError.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 14/01/2022.
//  Copyright © 2022 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension TrackingIdentifierError {

    init(serviceError: ServiceError) {
        switch serviceError {
        case .genericError:
            self = .genericError

        case .requestError(let error):
            self = .requestError(error: error)

        case .responseError(let statusCode):
            let info: [String: Any] = [
                "httpStatusCode": statusCode,
                "message": "Server returned unexpected response"
            ]
            let statusCodeError = NSError(domain: "TrackingIdentifierError", code: 1, userInfo: info)

            self = .responseError(error: statusCodeError)

        case .decodingError(let error):
            self = .responseError(error: error)

        case .missingDecodedTrackingIdentifier:
            let info: [String: Any] = [
                "message": "Tracking identifier was not present in backend response"
            ]
            let statusCodeError = NSError(domain: "TrackingIdentifierError", code: 2, userInfo: info)

            self = .responseError(error: statusCodeError)
        case .missingEaUUID:
            self = .genericError
        }
    }
}
