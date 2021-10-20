//
//  ConsentStringDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class ConsentStringDecorator: Decorator {

    let consentProvider: ConsentProviding

    init(consentProvider: ConsentProviding = ConsentProvider()) {
        self.consentProvider = consentProvider
    }

    var parameters: [String: AnyHashable] {
        if let publisherConsent = consentProvider.adpc {
            return [
                "_adpc": publisherConsent
            ]
        } else {
            return [:]
        }
    }
}
