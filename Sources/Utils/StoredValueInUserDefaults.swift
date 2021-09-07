//
//  StoredValueInUserDefaults.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 07/09/2021.
//

import Foundation

@propertyWrapper
struct StoredValueInUserDefaults<T> {

    private let defaults = UserDefaults.standard
    private let key: String

    var wrappedValue: T? {
        get {
            switch T.self {
            case is Date.Type:
                guard let saveInterval = defaults.object(forKey: key) as? Double else { return nil }

                return Date(timeIntervalSince1970: saveInterval) as? T

            default:
                return defaults.object(forKey: key) as? T
            }
        }
        set {
            switch T.self {
            case is Date.Type:
                let newDate = (newValue as? Date)?.timeIntervalSince1970
                defaults.set(newDate, forKey: key)

            default:
                defaults.set(newValue, forKey: key)
            }
        }
    }

    // MARK: Init

    init(key: String) {
        self.key = key
    }
}
