//
//  ContentPageViewSource.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Content page view event source
public enum ContentPageViewSource {

    /// Content was displayed in the app after normal user interaction, for example selecting article on the list
    case `default`

    /// Content was displayed after opening push notification
    case pushNotiifcation

    /// Content was displayed after interacting with uniwersal link / deep link on social media
    case socialMedia
}
