//
//  TrackingIdentifierError.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 14/01/2022.
//  Copyright © 2022 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// TrackingIdentifierError
public enum TrackingIdentifierError: Error {

    /// Unexpected error occured
    case genericError

    /// There was networking problem during tracking identifier request
    case requestError(error: Error)

    /// Backend had problem to process tracking identifier request and returned unexpected response
    case responseError(error: Error)
}
