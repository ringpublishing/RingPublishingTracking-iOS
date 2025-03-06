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
        if let area = applicationAdvertisementArea {
            return [
                "DA": area
            ]
        } else {
            return [
                "DA": applicationAdvertisementSite
            ]
        }
    }
}

extension AdAreaDecorator {

    func updateApplicationAdvertisementArea(applicationAdvertisementArea: String) {
        self.applicationAdvertisementArea = applicationAdvertisementArea
    }
    
    func updateApplicationAdvertisementSite(applicationAdvertisementSite: String) {
        self.applicationAdvertisementSite = applicationAdvertisementSite
    }
}
