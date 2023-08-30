//
//  VideoAdsConfiguration+ParameterName.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 23/08/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension VideoAdsConfiguration {

    var noAdsParameterName: String? {
        switch self {
        case .enabled:
            return nil

        case .disabledByConfiguration:
            return "ea"

        case .disabledByVideoContent:
            return "nb"

        case .disabledWithGracePeriod:
            return "gp"
        }
    }
}
