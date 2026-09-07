//
//  ContentViewType.swift
//  RingPublishingTracking
//
//  Created by Jakub Kacprzyk on 03/09/2026.
//

import Foundation

/// Mode in which given content is presented to the user
public enum ContentViewType: String, Encodable {

    /// Content is presented as text
    case text

    /// Content is read out loud using text to speech
    case tts

    /// Content is presented as a smart short
    case smartshort
}
