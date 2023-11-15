//
//  UserDefaultsStorage.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 20/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class UserDefaultsStorage: TrackingStorage {

    @StoredValueInUserDefaults(key: "eaUUID", storage: UserDefaults.standard)
    var eaUUID: EaUUID?

    @StoredValueInUserDefaults(key: "artemisID", storage: UserDefaults.standard)
    var artemisID: Artemis?

    @StoredValueInUserDefaults(key: "trackingIds", storage: UserDefaults.standard)
    var trackingIds: [String: IdsWithLifetime]?

    @StoredValueInUserDefaults(key: "postInterval", storage: UserDefaults.standard)
    var postInterval: Int?

    @StoredValueInUserDefaults(key: "randomUniqueDeviceId", storage: UserDefaults.standard)
    var randomUniqueDeviceId: String?
}
