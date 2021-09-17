//
//  AppTrackingConfiguration.swift
//  AppTracking
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Configuration of AppTracking SDK
public struct AppTrackingConfiguration {

    /// Tenant identifier
    public let tenantId: String

    /// API key
    public let apiKey: String

    /// API url
    public let apiUrl: URL?

    /// Application root area, for example app name like "onet" or "blick".
    /// This value will be used together with application current area to identify app screen
    public let applicationRootArea: String

    /// Application default area, for example "list/sport".
    /// If no new value will be set during app session, this value will be always used.
    public let applicationDefaultArea: String

    /// Default ad space name of the application, for example "ads/list/sport"
    /// If no new value will be set during app session, this value will be always used.
    public let applicationDefaultAdvertisementArea: String?

    // MARK: Init

    /// Initialize for configuration data used in AppTracking SDK
    ///
    /// - Parameters:
    ///   - tenantId: Identifier of the tenant
    ///   - apiKey: API key
    ///   - apiUrl: Optional API url. If not set, default endpoint will be used.
    ///   - applicationRootArea: Application root area, for example app name like "onet" or "blick".
    ///   - applicationDefaultArea: Application default area, for example "list/sport".
    ///   - applicationDefaultAdvertisementArea: Default ad space name of the application, for example "ads/list/sport"
    public init(tenantId: String,
                apiKey: String,
                apiUrl: URL? = nil,
                applicationRootArea: String,
                applicationDefaultArea: String,
                applicationDefaultAdvertisementArea: String? = nil) {
        self.tenantId = tenantId
        self.apiKey = apiKey
        self.apiUrl = apiUrl
        self.applicationRootArea = applicationRootArea
        self.applicationDefaultArea = applicationDefaultArea
        self.applicationDefaultAdvertisementArea = applicationDefaultAdvertisementArea
    }
}
