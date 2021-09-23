//
//  Optional+Logable.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 20/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension Optional {

    /// Use this wrapper to log optional value without wrapping it in Optional(...) description
    var logable: Any {
        switch self {
        case .none:
            return "nil"

        case let .some(value):
            return value
        }
    }
}
