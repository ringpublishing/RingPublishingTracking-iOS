//
//  Configuration.swift
//  Configuration
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Configuration of AppTracking SDK
public struct Configuration {

    /// Tenant identifier
    public let tenantId: String

    /// API key
    public let apiKey: String

    /// Publication's root name
    public let publicationsRootName: String

    /// API url
    public let apiUrl: URL?

    /// Initialize for configuration data used in AppTracking SDK
    /// - Parameters:
    ///   - tenantId: Identifier of the tenant
    ///   - apiKey: API key
    ///   - publicationsRootName: Publication's root name
    ///   - apiUrl: API url
    public init(tenantId: String, apiKey: String, publicationsRootName: String, apiUrl: URL? = nil) {
        self.tenantId = tenantId
        self.apiKey = apiKey
        self.publicationsRootName = publicationsRootName
        self.apiUrl = apiUrl
    }
}
