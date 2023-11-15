//
//  ArtemisExternal.swift
//
//
//  Created by Adam Mordavsky on 15.11.23.
//

import Foundation

/// Artemis External model wrapper
public struct ArtemisExternal: Codable {

    let model: String

    let models: [String: AnyCodable]
}
