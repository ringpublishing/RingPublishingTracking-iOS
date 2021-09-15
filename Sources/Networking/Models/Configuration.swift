//
//  Configuration.swift
//  Configuration
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public struct Configuration {
    let tenantId: String
    let apiKey: String
    let publicationsRootName: String
    let apiUrl: URL?

    public init(tenantId: String, apiKey: String, publicationsRootName: String, apiUrl: URL? = nil) {
        self.tenantId = tenantId
        self.apiKey = apiKey
        self.publicationsRootName = publicationsRootName
        self.apiUrl = apiUrl
    }
}
