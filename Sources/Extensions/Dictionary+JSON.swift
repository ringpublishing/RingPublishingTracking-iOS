//
//  Dictionary+JSON.swift
//  AppTracking-Example
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
        try JSONSerialization.data(withJSONObject: self, options: [.sortedKeys])
    }
}
