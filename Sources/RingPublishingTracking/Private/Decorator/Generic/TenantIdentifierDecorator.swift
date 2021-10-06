//
//  TenantIdentifierDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 05/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct TenantIdentifierDecorator: Decorator {
    
    private let tenantId: String

    init(tenantId: String) {
        self.tenantId = tenantId
    }

    func parameters() -> [String: String] {
        [
            "TID": tenantId
        ]
    }
}
