//
//  Dictionary+JSON.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 20/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {

    /// Size in bytes of the dictionary after JSON serialization
    var jsonSizeInBytes: UInt {
        do {
            let data = try dataUsingJSONSerialization()
            return UInt(data.count)
        } catch {
            return 0
        }
    }

    /// Serializes dictionary into JSON data object
    /// - Returns: Data
    func dataUsingJSONSerialization() throws -> Data {
        let options: JSONSerialization.WritingOptions
        if #available(iOS 13.0, *) {
            options = [.sortedKeys, .withoutEscapingSlashes]
        } else {
            options = [.sortedKeys]
        }

        return try JSONSerialization.data(withJSONObject: self, options: options)
    }
}
