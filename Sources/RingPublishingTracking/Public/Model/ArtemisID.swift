//
//  ArtemisID.swift
//
//
//  Created by Adam Mordavsky on 15.11.23.
//

import Foundation

/// Artemis ID wrapper
public struct ArtemisID: Codable {

    let artemis: String

    let external: ArtemisExternal
}
