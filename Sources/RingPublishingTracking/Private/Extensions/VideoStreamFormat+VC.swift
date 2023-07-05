//
//  VideoStreamFormat+VC.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//

import Foundation

extension VideoStreamFormat {

    var vcParameterFormatName: String {
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
