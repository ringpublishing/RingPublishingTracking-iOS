//
//  TenantIdentifierDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 05/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class TenantIdentifierDecorator: Decorator {

    private var tenantId: String?

    var parameters: [String: AnyHashable] {
        guard let tenantId = tenantId else {
            return [:]
        }

        return [
            "TID": tenantId
        ]
    }
}

extension TenantIdentifierDecorator {

    func updateTenantId(tenantId: String) {
        self.tenantId = tenantId
    }
}
