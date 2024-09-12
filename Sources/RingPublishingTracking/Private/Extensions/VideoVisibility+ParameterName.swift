//
//  VideoVisibility+ParameterName.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 23/08/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension VideoVisibility {

    /// Visibility parameter
    /// Example: {"context":{"visible":"out-of-viewport"}} as Base64 encoded string
    var parameterName: String? {
        let visibilityParamName: String

        switch self {
        case .visible:
            visibilityParamName = "visible"

        case .outOfViewport:
            visibilityParamName = "out-of-viewport"
        }

        let visibilityData = VideoVisibilityWrapper(context: VideoVisibilityContext(visible: visibilityParamName))

        return visibilityData.jsonStringBase64
    }
}

private struct VideoVisibilityWrapper: Encodable {

    let context: VideoVisibilityContext
}

private struct VideoVisibilityContext: Encodable {

    let visible: String
}
