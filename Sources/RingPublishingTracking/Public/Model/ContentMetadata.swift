//
//  ContentMetadata.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Content metadata
public struct ContentMetadata {

    /// Publication identifier in source system (CMS)
    public let publicationId: String

    /// Publication website URL
    public let publicationUrl: URL

    /// Source system (CMS) name
    public let sourceSystemName: String

    /// Index of displayed content part (applies only if given content can be consumed in parts).
    /// Default value is set to 1.
    public let contentPartIndex: Int

    /// Did user paid for access to this content?
    public let contentWasPaidFor: Bool

    // MARK: Init

    /// Initializer
    ///
    /// - Parameters:
    ///   - publicationId: Publication identifier in source system (CMS)
    ///   - publicationUrl: Website url address for given publication
    ///   - sourceSystemName: Source system (CMS) name
    ///   - contentPartIndex: Index of displayed content part (applies only if given content can be consumed in parts).
    ///   - contentWasPaidFor: Did user pay for access to this content?
    public init(publicationId: String,
                publicationUrl: URL,
                sourceSystemName: String,
                contentPartIndex: Int = 1,
                contentWasPaidFor: Bool) {
        self.publicationId = publicationId
        self.publicationUrl = publicationUrl
        self.sourceSystemName = sourceSystemName
        self.contentPartIndex = contentPartIndex
        self.contentWasPaidFor = contentWasPaidFor
    }
}

/// Extension to make ContentMetadata comparable
extension ContentMetadata: Equatable {}
