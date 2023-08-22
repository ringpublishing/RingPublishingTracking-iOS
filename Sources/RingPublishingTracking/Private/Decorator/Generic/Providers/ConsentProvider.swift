//
//  ConsentProvider.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

class ConsentProvider: NSObject, ConsentProviding {

    private let tcfv2StorageKey = "IABTCF_TCString"

    private var observerCallback: ((_ tcfv2: String?) -> Void)?

    var tcfv2: String? {
        return UserDefaults.standard.string(forKey: tcfv2StorageKey)
    }

    // MARK: Life cycle

    override init() {
        super.init()

        UserDefaults.standard.addObserver(self, forKeyPath: tcfv2StorageKey, context: nil)
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: tcfv2StorageKey)
        observerCallback = nil
    }

    // MARK: Methods

    func observeConsentsChange(observerCallback: ((_ tcfv2: String?) -> Void)?) {
        self.observerCallback = observerCallback

    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == tcfv2StorageKey else { return }

        observerCallback?(tcfv2)
    }
}
