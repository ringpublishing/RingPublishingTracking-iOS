//
//  EventResponse.swift
//  EventResponse
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Structure of the JSON response for Event Request
struct EventResponse: Decodable {

    /// Minimum time in milliseconds between consequitve HTTP requests
    let postInterval: Int
}
