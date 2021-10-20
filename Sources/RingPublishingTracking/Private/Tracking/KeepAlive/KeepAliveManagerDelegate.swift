//
//  KeepAliveManagerDelegate.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 15/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol KeepAliveManagerDelegate: AnyObject {

    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource,
                          didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus
    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata)
}
