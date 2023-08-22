//
//  SizeDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import CoreGraphics

final class SizeDecorator: Decorator {

    private let screenDepth = 24
    private let sizeProvider: SizeProviding

    var parameters: [String: AnyHashable] {
        [
            "CS": formatSize(for: sizeProvider.screenSize) + "x\(screenDepth)",
            "CW": formatSize(for: sizeProvider.applicationSize)
        ]
    }

    // MARK: Init

    init(sizeProvider: SizeProviding = SizeProvider()) {
        self.sizeProvider = sizeProvider
    }
}

// MARK: Private
private extension SizeDecorator {

    func formatSize(for size: CGSize) -> String {
        return "\(Int(size.width))x\(Int(size.height))"
    }
}
