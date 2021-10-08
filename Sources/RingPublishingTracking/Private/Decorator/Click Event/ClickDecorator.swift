//
//  ClickDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 08/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class ClickDecorator: Decorator {

    private let selectedElementName: String?
    private let publicationUrl: URL?

    init(selectedElementName: String?, publicationUrl: URL?) {
        self.selectedElementName = selectedElementName
        self.publicationUrl = publicationUrl
    }

    func parameters() -> [String: AnyHashable] {
        var params: [String: AnyHashable] = [:]

        if let selectedElementName = selectedElementName {
            params["VE"] = selectedElementName
        }

        if let publicationUrl = publicationUrl {
            params["VU"] = publicationUrl.absoluteString
        }

        return params
    }
}
