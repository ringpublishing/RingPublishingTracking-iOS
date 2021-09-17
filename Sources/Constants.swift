//
//  Constants.swift
//  Constants
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

// swiftlint:disable force_unwrapping

struct Constants {

    // MARK: API

    static let apiUrl: URL = URL(string: "https://events.ocdn.eu")!
    static let apiVersion: String = "v3"

    // MARK: Config

    static let applicationDefaultStructurePath = "undefined"
    static let applicationDefaultAdvertisementArea = "undefined"

    // MARK: Event params

    static let eventDefaultAnalyticsSystemName = "_GENERIC"
    static let eventDefaultName = "Event"
}
