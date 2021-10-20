//
//  AtomicArray.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 23/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class AtomicArray<T> {
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

    func removeFirst( _ count: Int) {
        queue.sync(flags: .barrier) {
            storage.removeFirst(count)
        }
    }
}
