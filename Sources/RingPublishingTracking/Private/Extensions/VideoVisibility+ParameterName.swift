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

        // swiftlint:disable non_optional_string_data_conversion
        guard let jsonData = try? JSONEncoder().encode(visibilityData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        // swiftlint:enable non_optional_string_data_conversion

        return Data(jsonString.utf8).base64EncodedString()
    }
}

private struct VideoVisibilityWrapper: Encodable {

    let context: VideoVisibilityContext
}

private struct VideoVisibilityContext: Encodable {

    let visible: String
}
