//
//  Constants.swift
//  Constants
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct Constants {

    /// API url
    static let apiUrl: URL = URL(string: "https://events.ocdn.eu")!

    /// Current version of API
    static let apiVersion: String = "v3"

    /// Size limit in bytes of events that might be send in a single request
    static let eventSizeLimit = UInt(16000)

    /// Size limit of  body for single events request
    static let requestBodySizeLimit = UInt(1000 * 1000)
}
