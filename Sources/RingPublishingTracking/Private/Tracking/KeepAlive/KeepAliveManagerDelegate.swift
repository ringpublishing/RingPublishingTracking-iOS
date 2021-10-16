//
//  KeepAliveManagerDelegate.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 15/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol KeepAliveManagerDelegate: AnyObject {

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata)
}
