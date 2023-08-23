//
//  VideoAdsConfiguration+ParameterName.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 23/08/2023.
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
