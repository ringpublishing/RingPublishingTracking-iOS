//
//  SampleArticle.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct SampleArticle {

    let title: String
    let publicationId: String = generatePublicationId()
    let publicationUrl: URL
    let sourceSystemName: String = "My Awesome CMS"
    let contentWasPaidFor: Bool
}

// MARK: Private
private extension SampleArticle {

    static func generatePublicationId() -> String {
        return UUID().uuidString
    }
}
