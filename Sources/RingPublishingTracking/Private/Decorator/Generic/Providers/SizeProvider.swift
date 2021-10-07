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
        UIScreen.main.nativeBounds.size
    }

    var applicationSize: CGSize {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: \.isKeyWindow) ?? UIApplication.shared.keyWindow

            return window?.frame.size ?? .zero
        } else {
            return UIApplication.shared.keyWindow?.frame.size ?? .zero
        }
    }
}
