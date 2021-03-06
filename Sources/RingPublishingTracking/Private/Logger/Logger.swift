//
//  Logger.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 07/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import os.log

/// Logger
class Logger {

    /// Shared instance
    static let shared = Logger()

    /// Logger instance
    private let logger: OSLog

    /// Closure which can be used to gather module logs inside host application
    var loggerOutput: ((_ message: String) -> Void)?

    // MARK: Init

    private init() {
        self.logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "application", category: "RingPublishingTracking")
    }

    deinit {
        loggerOutput = nil
    }

    // MARK: Methods

    class func log(_ message: String,
                   level: OSLogType = .info,
                   file: String = #file,
                   functionName: String = #function,
                   lineNumber: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let messageWithMetadata = "[\(fileName):\(lineNumber) \(functionName)] \(message)"

        os_log("%{public}@", log: Self.shared.logger, type: level, messageWithMetadata)
        Self.shared.loggerOutput?(messageWithMetadata)
    }
}
