//
//  IdsWithLifetime.swift
//  IdsWithLifetime
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct IdsWithLifetime: Codable {

    /// The identifier
    let value: String?

    /// The time in seconds of how long the identifier is valid for since the refresh's date
    let lifetime: Int?
}
