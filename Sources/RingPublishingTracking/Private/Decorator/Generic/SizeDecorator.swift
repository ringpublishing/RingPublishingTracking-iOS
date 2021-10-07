//
//  SizeDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

protocol SizeProviding {

    var screenSize: CGSize { get }
    var applicationSize: CGSize { get }
}

struct SizeProvider: SizeProviding {

    var screenSize: CGSize {
        UIScreen.main.nativeBounds.size
    }

    var applicationSize: CGSize {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: \.isKeyWindow)?.frame.size ?? .zero
        } else {
            return UIApplication.shared.keyWindow?.frame.size ?? .zero
        }
    }
}

final class SizeDecorator: Decorator {

    private let screenDepth = 24
    private let sizeProvider: SizeProviding

    init(sizeProvider: SizeProviding = SizeProvider()) {
        self.sizeProvider = sizeProvider
    }

    func parameters() -> [String: String] {
        [
            "CS": formatSize(for: sizeProvider.screenSize),
            "CV": formatSize(for: sizeProvider.applicationSize)
        ]
    }

    private func formatSize(for size: CGSize) -> String {
        "\(Int(size.height))x\(Int(size.width))x\(screenDepth)"
    }
}
