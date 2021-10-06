//
//  EventsServiceDelegate.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 30/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Events Service delegate
protocol EventsServiceDelegate: AnyObject {

    func eventsService(_ eventsService: EventsService, retrievedtrackingIdentifier identifier: String)
}
