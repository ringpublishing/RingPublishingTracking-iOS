//
//  AdAreaDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class AdAreaDecorator: Decorator {

    private var applicationAdvertisementArea: String?
    private var applicationAdvertisementSite: String?

    var parameters: [String: AnyHashable] {
        // An empty half is treated as absent, so DA never carries a bare leading or trailing separator.
        let components = [applicationAdvertisementSite, applicationAdvertisementArea].compactMap { $0 }.filter { !$0.isEmpty }

        return [
            "DA": components.joined(separator: "/")
        ]
    }
}

extension AdAreaDecorator {

    func updateApplicationAdvertisementArea(applicationAdvertisementArea: String?) {
        self.applicationAdvertisementArea = applicationAdvertisementArea
    }

    func updateApplicationAdvertisementSite(applicationAdvertisementSite: String?) {
        self.applicationAdvertisementSite = applicationAdvertisementSite
    }
}
