//
//  ServiceError.swift
//  ServiceError
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Error used for issues with making network requests
enum ServiceError: Error {
    case genericError
    case requestError(error: Error)
    case responseError(statusCode: Int)
    case decodingError(error: Error)
    case missingDecodedTrackingIdentifier
    case missingEaUUID
}
