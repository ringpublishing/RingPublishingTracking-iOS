//
//  ConsentStringDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol ConsentProviding {

    var adpc: String? { get }
}

struct ConsentProvider: ConsentProviding {

    var adpc: String? {
        UserDefaults.standard.string(forKey: "IABTCF_TCString")
    }
}

final class ConsentStringDecorator: Decorator {

    let consentProvider: ConsentProviding

    init(consentProvider: ConsentProviding = ConsentProvider()) {
        self.consentProvider = consentProvider
    }

    func parameters() -> [String: String] {
        if let publisherConsent = consentProvider.adpc {
            return [
                "_adpc": publisherConsent
            ]
        } else {
            return [:]
        }
    }
}
