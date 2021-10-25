//
//  EventsQueueManagerDelegate.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 29/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// EventsQueueManager's delegate
protocol EventsQueueManagerDelegate: AnyObject {

    func eventsQueueBecameReadyToSendEvents(_ eventsQueueManager: EventsQueueManager)
    func eventsQueueFailedToScheduleTimer(_ eventsQueueManager: EventsQueueManager)
    func eventsQueueFailedToAddEvent(_ eventsQueueManager: EventsQueueManager, event: Event)
}
