//
//  EventRequest.swift
//  EventRequest
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct EventRequest: Encodable {

    let ids: [String: String]
    let user: User
    let events: [ReportedEvent]
}
