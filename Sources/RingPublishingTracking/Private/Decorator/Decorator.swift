//
//  Decorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol Decorator {

    var parameters: [String: AnyHashable] { get }

    /// Called after this decorator's `parameters` have been applied to a decorated event
    func eventDecorated()
}

extension Decorator {

    func eventDecorated() {
        // No-op by default
    }
}
