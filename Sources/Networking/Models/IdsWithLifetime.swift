//
//  IdsWithLifetime.swift
//  IdsWithLifetime
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct IdsWithLifetime: Decodable {
    let value: String?
    let lifetime: Int?
}
