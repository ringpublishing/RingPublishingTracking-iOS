//
//  VideoStreamFormat+ParameterName.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension VideoStreamFormat {

    var parameterFormatName: String {
        switch self {
        case .flv:
            return "flv"

        case .mp4:
            return "mp4"

        case .manifest:
            return "manifest"

        case .liveManifest:
            return "manifestlive"

        case .thirdGenerationPartnership:
            return "3gp"

        case .hds:
            return "hds"

        case .hls:
            return "hls"

        case .rtsp:
            return "rtsp"
        }
    }
}
