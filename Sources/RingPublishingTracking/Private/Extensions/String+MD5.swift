//
//  String+MD5.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 14/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

/// Extension for String to create MD5 hash
extension String {
    func md5() -> String? {
        guard let data = data(using: .utf8) else {
            return nil
        }

        let digest = Insecure.MD5.hash(data: data)

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
