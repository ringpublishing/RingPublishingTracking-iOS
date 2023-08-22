//
//  VideoStartMode+ParameterName.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 22/08/2023.
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
