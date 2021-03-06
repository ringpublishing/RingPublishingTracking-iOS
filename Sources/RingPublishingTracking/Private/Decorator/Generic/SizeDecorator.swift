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

    init(sizeProvider: SizeProviding = SizeProvider()) {
        self.sizeProvider = sizeProvider
    }

    var parameters: [String: AnyHashable] {
        [
            "CS": formatSize(for: sizeProvider.screenSize) + "x\(screenDepth)",
            "CW": formatSize(for: sizeProvider.applicationSize)
        ]
    }

    private func formatSize(for size: CGSize) -> String {
        "\(Int(size.width))x\(Int(size.height))"
    }
}
