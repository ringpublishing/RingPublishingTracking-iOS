//
//  Profile.swift
//  Profile
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Additional tracking data for current user
struct Profile: Codable {

    /// Tracking data, ie. audience segments
    let segments: [String: String]?
}
