//
//  UserAgent.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 07/09/2021.
//

import Foundation
import UIKit

// Helper class for user agent used in AppTracking network requests
class UserAgent {

    /// Returns default User Agent which should be used across all requestsused by AppTracking
    static var appTrackingUserAgent: String {
        let deviceCategory = Self.deviceCategoryName
        let systemDescription = Self.systemForUserAgent(with: deviceCategory.name)
        let dreamlabDescription = deviceCategory.isIpad ? "RingPublishing" : "Mobile RingPublishing"
        let appName = Self.removeUnallowedCharacters(from: UserAgent.appDisplayName).trimmingCharacters(in: .whitespacesAndNewlines)

        let userAgent = "Mozilla/5.0 \(deviceCategory.name); \(systemDescription); \(dreamlabDescription)" +
        " \(appName)/\(Self.appMarketingVersion)"

        return Self.removeUnallowedCharacters(from: userAgent)
    }

    // MARK: Init

    private init() {

    }
}

// MARK: Private
private extension UserAgent {

    /// App display name
    static var appDisplayName: String {
        var appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String

        if appName?.isEmpty ?? true {
            appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        }

        return appName ?? ""
    }

    /// App marketing version
    static var appMarketingVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }

    /// Returns either iPhone or iPad
    static var deviceCategoryName: (name: String, isIpad: Bool) {
        let model = Self.deviceModel()
        var deviceCategoryName = "iPhone"
        var isIpad = false

        if model.lowercased().contains("ipad") {
            deviceCategoryName = "iPad"
            isIpad = true
        }

        return (name: deviceCategoryName, isIpad: isIpad)
    }

    /// Returns system description
    ///
    /// - Parameter category: Device category name
    /// - Returns: System for user agent
    static func systemForUserAgent(with category: String) -> String {
        let iOSVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")

        return "CPU \(category) OS \(iOSVersion) like Mac OS X"
    }

    /// Removes unallowed characters in http header
    ///
    /// - Parameter userAgent: String
    static func removeUnallowedCharacters(from userAgent: String) -> String {
        let allowedCharacters = CharacterSet.urlPathAllowed
            .union(CharacterSet.whitespacesAndNewlines)
            .union(CharacterSet.punctuationCharacters)

        return String(userAgent.unicodeScalars.filter { allowedCharacters.contains($0) })
    }

    /// Name of phone model, e.g. iPod5,1 or iPad7,4
    static func deviceModel() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hwMachine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hwMachine, &size, nil, 0)

        return String(cString: hwMachine)
    }
}
