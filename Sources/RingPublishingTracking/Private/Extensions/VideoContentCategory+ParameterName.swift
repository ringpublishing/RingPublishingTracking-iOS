//
//  VideoContentCategory+ParameterName.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 23/08/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension VideoContentCategory {

    var parameterName: String {
        switch self {
        case .free:
            return "free"

        case .vodPayPerView:
            return "tvod"

        case .vodSubscription:
            return "svod"
        }
    }
}
