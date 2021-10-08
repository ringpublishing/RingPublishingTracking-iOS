//
//  ConsentProvider.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct ConsentProvider: ConsentProviding {

    var adpc: String? {
        UserDefaults.standard.string(forKey: "IABTCF_TCString")
    }
}
