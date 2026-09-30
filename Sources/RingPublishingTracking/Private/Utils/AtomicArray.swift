//
//  AtomicArray.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 23/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class AtomicArray<T: Equatable> {

    private var storage: [T] = []

    private let queue = DispatchQueue(label: "events.concurrent.queue", attributes: .concurrent)

    var allElements: [T] {
        queue.sync {
            storage
        }
    }

    func append(_ element: T) {
        queue.sync(flags: .barrier) {
            storage.append(element)
        }
    }

    func removeItems(_ items: [T]) {
        queue.sync(flags: .barrier) {
            items.forEach { item in
                storage.removeAll(where: { $0 == item })
            }
        }
    }
}
