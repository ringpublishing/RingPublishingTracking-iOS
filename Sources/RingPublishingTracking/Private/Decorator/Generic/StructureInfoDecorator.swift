//
//  StructureInfoDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

enum StructureType {

    case publicationUrl(URL, [String])
    case structurePath([String])

    func parametersResolved(with applicationRootPath: String) -> (dv: String, du: String) {
        let dvField: String
        let duField: String

        switch self {
        case .publicationUrl(let url, let array):
            dvField = formatFieldDV(for: applicationRootPath, array: array)
            duField = url.absoluteString
        case .structurePath(let array):
            dvField = formatFieldDV(for: applicationRootPath, array: array)
            duField = "https://\(applicationRootPath).\(Constants.applicationPrefix)/\(array.joined(separator: "/"))".lowercased()
        }

        return (dvField, duField)
    }

    private func formatFieldDV(for applicationRootPath: String, array: [String]) -> String {
        ([applicationRootPath + ".\(Constants.applicationPrefix)"] + array).joined(separator: "/").lowercased()
    }
}

final class StructureInfoDecorator: Decorator {

    private(set) var applicationRootPath: String?
    private(set) var structureType: StructureType?
    private(set) var contentPageViewSource: ContentPageViewSource?
    private(set) var previousInfo: (structureType: StructureType?, contentPageViewSource: ContentPageViewSource?)

    var parameters: [String: AnyHashable] {
        guard
            let structureType = structureType,
            let applicationRootPath = applicationRootPath
        else {
            return [:]
        }

        let resolved = structureType.parametersResolved(with: applicationRootPath)
        var params = [
            "DV": resolved.dv,
            "DU": resolved.du + contentPageViewSource.utmMedium
        ]

        if let previousStructureType = previousInfo.structureType {
            let source = previousInfo.contentPageViewSource
            params["DR"] = previousStructureType.parametersResolved(with: applicationRootPath).du + source.utmMedium
        }

        return params
    }
}

extension StructureInfoDecorator {

    func updateStructureType(structureType: StructureType, contentPageViewSource: ContentPageViewSource?) {
        self.previousInfo = (self.structureType, self.contentPageViewSource)
        self.structureType = structureType
        self.contentPageViewSource = contentPageViewSource
    }

    func updateApplicationRootPath(applicationRootPath: String) {
        self.applicationRootPath = applicationRootPath
    }
}

extension Optional where Wrapped == ContentPageViewSource {
    var utmMedium: String {
        let medium: String
        switch self {
        case .pushNotifcation:
            medium = "push"
        case .socialMedia:
            medium = "social"
        case .default, .none:
            return ""
        }

        return "?utm_medium=\(medium)"
    }
}
