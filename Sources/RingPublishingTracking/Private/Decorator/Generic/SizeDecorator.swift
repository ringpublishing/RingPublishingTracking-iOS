//
//  SizeDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

final class SizeDecorator: Decorator {

    private let screenDepth = 24

    func parameters() -> [String: String] {
        let screenSize = UIScreen.main.nativeBounds.size

        let applicationSize: CGSize
        if #available(iOS 13.0, *) {
            applicationSize = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: \.isKeyWindow)?.frame.size ?? .zero
        } else {
            applicationSize = UIApplication.shared.keyWindow?.frame.size ?? .zero
        }

        return [
            "CS": formatSize(for: screenSize),
            "CV": formatSize(for: applicationSize)
        ]
    }

    private func formatSize(for size: CGSize) -> String {
        "\(Int(size.height))x\(Int(size.width))x\(screenDepth)"
    }
}
