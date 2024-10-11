//
//  AudioOutput.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//

import Foundation

/// Audio output type
public enum AudioOutput: String, Encodable {

    /// Audio is being played on mobile device
    case mobile

    /// Audio is being airPlayed
    case airPlay

    /// Audio is being played on car audio system
    case car

    /// Audio is being played on bluetooth device
    case bluetooth

    /// Audio is being played on external device
    case external
}
