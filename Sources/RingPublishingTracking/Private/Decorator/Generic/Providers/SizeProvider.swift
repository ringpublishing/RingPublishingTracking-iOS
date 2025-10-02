//
//  SizeProvider.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

struct SizeProvider: SizeProviding {

    var screenSize: CGSize {
        UIScreen.main.bounds.size
    }

    var applicationSize: CGSize {
        let window = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: \.isKeyWindow)

        return window?.frame.size ?? .zero
    }
}
