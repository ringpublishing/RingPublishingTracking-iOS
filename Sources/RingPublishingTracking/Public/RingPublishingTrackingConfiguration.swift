//
//  RingPublishingTrackingConfiguration.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Configuration of RingPublishingTracking SDK
public struct RingPublishingTrackingConfiguration {

    /// Tenant identifier
    public let tenantId: String

    /// API key
    public let apiKey: String

    /// API url
    public let apiUrl: URL?

    /// Application root path, for example app name like "onet" or "blick".
    /// This value will be used together with application current structure path to identify app screen
    public let applicationRootPath: String

    /// Application structure path used to identify application screen, for example "home/sport_list_screen".
    /// If no new value will be set during app session when reporting 'pageView', this value will be always used.
    public let applicationDefaultStructurePath: [String]

    /// Default ad space name of the application, for example "ads/list/sport"
    /// If no new value will be set during app session, this value will be always used.
    public let applicationDefaultAdvertisementArea: String

    /// Application advertisement site, which is used as a prefix for all advertisement areas
    public let applicationAdvertisementSite: String?

    /// Flag indicating if effective page view event is enabled.
    public let shouldReportEffectivePageViewEvent: Bool

    // MARK: Init

    /// Initialize for configuration data used in RingPublishingTracking SDK
    ///
    /// - Parameters:
    ///   - tenantId: Identifier of the tenant
    ///   - apiKey: API key
    ///   - apiUrl: Optional API url. If not set, default endpoint will be used.
    ///   - aapplicationRootPath: Application root path, for example app name like "onet" or "blick".
    ///   - applicationDefaultStructurePath: Application default area, for example "home_screen", "undefined" by default
    ///   - applicationDefaultAdvertisementArea: Default ad space name of the application,
    ///   for example "ads/list/sport", "undefined" by default
    public init(tenantId: String,
                apiKey: String,
                apiUrl: URL? = nil,
                applicationRootPath: String,
                applicationDefaultStructurePath: [String]? = nil,
                applicationDefaultAdvertisementArea: String? = nil,
                applicationAdvertisementSite: String? = nil,
                shouldReportEffectivePageViewEvent: Bool = true) {
        self.tenantId = tenantId
        self.apiKey = apiKey
        self.apiUrl = apiUrl
        self.applicationRootPath = applicationRootPath
        self.applicationDefaultStructurePath = applicationDefaultStructurePath ?? Constants.applicationDefaultStructurePath
        self.applicationDefaultAdvertisementArea = applicationDefaultAdvertisementArea ?? Constants.applicationDefaultAdvertisementArea
        self.applicationAdvertisementSite = applicationAdvertisementSite
        self.shouldReportEffectivePageViewEvent = shouldReportEffectivePageViewEvent
    }
}
