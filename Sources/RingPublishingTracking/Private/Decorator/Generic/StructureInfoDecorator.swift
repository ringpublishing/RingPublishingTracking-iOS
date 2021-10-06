//
//  StructureInfoDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

enum StructureType {

    case publicationUrl(String, [String])
    case structurePath([String])

    func parametersResolved(with applicationRootPath: String) -> (dv: String, du: String) {
        let dvField: String
        let duField: String

        switch self {
        case .publicationUrl(let url, let array):
            dvField = ([applicationRootPath] + array).joined(separator: "/")
            duField = url
        case .structurePath(let array):
            dvField = ([applicationRootPath] + array).joined(separator: "/")
            duField = "https://\(applicationRootPath).app.ios\(array.joined(separator: "/"))".lowercased()
        }

        return (dvField, duField)
    }
}

final class StructureInfoDecorator: Decorator {

    private(set) var applicationRootPath: String
    private(set) var structureType: StructureType?
    private(set) var previousStructureType: StructureType?

    init(applicationRootPath: String) {
        self.applicationRootPath = applicationRootPath
    }

    func parameters() -> [String: String] {
        guard let structureType = structureType else {
            return [:]
        }

        let resolved = structureType.parametersResolved(with: applicationRootPath)
        var params = [
            "DV": resolved.dv,
            "DU": resolved.du
        ]

        if let previousStructureType = previousStructureType {
            params["DR"] = previousStructureType.parametersResolved(with: applicationRootPath).du
        }

        return params
    }
}

extension StructureInfoDecorator {

    func updateStructureType(structureType: StructureType) {
        self.previousStructureType = self.structureType
        self.structureType = structureType
    }
}
