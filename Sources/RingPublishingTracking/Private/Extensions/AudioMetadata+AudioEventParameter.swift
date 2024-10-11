//
//  AudioMetadata+AudioEventParameter.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 11/10/2024.
//

import Foundation

extension AudioMetadata {
    var audioEventParameter: AudioEventParameter {
        AudioEventParameter(id: contentId,
                            seriesId: contentSeriesId,
                            title: contentTitle,
                            seriesTitle: contentSeriesTitle,
                            mediaType: mediaType)
    }
}
