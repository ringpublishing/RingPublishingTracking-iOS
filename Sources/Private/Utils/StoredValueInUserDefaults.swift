//
//  StoredValueInUserDefaults.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 07/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

@propertyWrapper
struct StoredValueInUserDefaults<T> {

    private let key: String
    private let storage: Storage

    var wrappedValue: T? {
        get {
            switch T.self {
            case is Date.Type:
                guard let saveInterval = storage.object(forKey: key) as? Double else { return nil }

                return Date(timeIntervalSince1970: saveInterval) as? T

            default:
                return storage.object(forKey: key) as? T
            }
        }
        set {
            switch T.self {
            case is Date.Type:
                let newDate = (newValue as? Date)?.timeIntervalSince1970
                storage.set(newDate, forKey: key)

            default:
                storage.set(newValue, forKey: key)
            }
        }
    }

    // MARK: Init

    /// Init
    ///
    /// - Parameters:
    ///   - key: Key under which value will be stored
    ///   - storage: Storage object (by default it is set to standard UserDefaults)
    init(key: String, storage: Storage = UserDefaults.standard) {
        self.key = key
        self.storage = storage
    }
}

// MARK: Storage

protocol Storage {

    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
}

// MARK: UserDefaults+Storage

extension UserDefaults: Storage {

}
