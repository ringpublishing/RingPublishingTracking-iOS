//
//  ConsentStringDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class ConsentStringDecorator: Decorator {

    func parameters() -> [String: String] {
        if let publisherConsent = UserDefaults.standard.string(forKey: "IABTCF_TCString") {
            return [
                "_adpc": publisherConsent
            ]
        } else {
            return [:]
        }
    }
}
