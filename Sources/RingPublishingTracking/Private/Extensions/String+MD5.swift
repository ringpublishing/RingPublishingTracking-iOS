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

        if #available(iOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: data)

            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        } else {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            var digest = Data(count: length)

            _ = digest.withUnsafeMutableBytes { digestBytes -> UInt8 in
                data.withUnsafeBytes { messageBytes -> UInt8 in
                    if let messageBytesBaseAddress = messageBytes.baseAddress,
                       let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                        let messageLength = CC_LONG(data.count)
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                    }
                    return 0
                }
            }

            return digest.map {
                String(format: "%02hhx", $0)
            }.joined()
        }
    }
}
