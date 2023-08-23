//
//  VideoStartMode+ParameterName.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 22/08/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension VideoStartMode {

    var parameterName: String {
        switch self {
        case .muted:
            return "ms"

        case .normal:
            return "ns"

        case .wasMuted:
            return "wm"
        }
    }
}
