//
//  IdentifyResponse.swift
//  IdentifyResponse
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Structure of the JSON response for Identify Request
struct IdentifyResponse: Decodable {

    /// Ids that should be stored in persistent storage
    let ids: [String: IdsWithLifetime]

    /// Additional tracking data for current user like audience segments
    let profile: Profile

    /// Minimum time in milliseconds between consequitve HTTP requests
    let postInterval: Int
}
