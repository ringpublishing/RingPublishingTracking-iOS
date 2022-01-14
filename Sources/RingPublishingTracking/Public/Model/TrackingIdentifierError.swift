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

    /// Debug / opt-out mode is enabled and tracking identifier will not be retrieved
    case debugModeEnabled

    /// Url constructed to fetch tracking identifier was invalid
    case invalidUrl

    /// Tracking identifier request body could not be parsed
    case incorrectRequestBody

    /// There was networking problem during tracking identifier request
    case requestError(error: Error)

    /// Tracking identifier request requires authorization heaaders but there were none provided
    case unauthorizedRequest

    /// Tracking identifier request was send but it was recognized as incorrect by the backend
    case clientError

    /// Backedn had problem to process tracking identifier request
    case serverError

    /// Tracking identifier request was returned from the backend but response could not be parsed
    case failedToDecode
}
