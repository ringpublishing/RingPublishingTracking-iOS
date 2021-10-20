//
//  EaUUID.swift
//  EaUUID
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// User identifier
struct EaUUID: Codable {

    /// The identifier
    let value: String

    /// The time in seconds of how long the identifier is valid for since the refresh's date
    let lifetime: Int

    /// Date when the identifier was created
    let creationDate: Date
}
