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
        case .debugModeEnabled:
            self = .debugModeEnabled
        case .invalidUrl:
            self = .invalidUrl
        case .incorrectRequestBody:
            self = .incorrectRequestBody
        case .unauthorized:
            self = .unauthorizedRequest
        case .failedToDecode:
            self = .failedToDecode
        case .clientError:
            self = .clientError
        case .serverError:
            self = .serverError
        case .requestError(let error):
            self = .requestError(error: error)
        }
    }
}
