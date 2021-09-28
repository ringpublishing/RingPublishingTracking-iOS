//
//  UserDefaultsStorage.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 20/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class UserDefaultsStorage: TrackingStorage {

    @StoredValueInUserDefaults(key: "eaUuid", storage: UserDefaults.standard)
    var eaUuid: EaUuid?

    @StoredValueInUserDefaults(key: "trackingIds", storage: UserDefaults.standard)
    var trackingIds: [String: IdsWithLifetime]?

    @StoredValueInUserDefaults(key: "postInterval", storage: UserDefaults.standard)
    var postInterval: Int?
}
