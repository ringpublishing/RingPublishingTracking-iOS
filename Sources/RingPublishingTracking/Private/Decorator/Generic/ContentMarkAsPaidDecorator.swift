//
//  ContentMarkAsPaidDecorator.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 03/09/2024.
//

import Foundation

class ContentMarkAsPaidDecorator: Decorator {

    private lazy var encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    private var contentMetadata: ContentMetadata
    private var contentMarkAsPaid: ContentMarkAsPaid

    init(contentMetadata: ContentMetadata) {
        self.contentMetadata = contentMetadata

        contentMarkAsPaid = ContentMarkAsPaid(contentMetadata: contentMetadata)
    }

    // swiftlint:disable non_optional_string_data_conversion

    var parameters: [String: AnyHashable] {
        var markedAsPaidParams: [String: String] = [:]

        if let jsonData = try? encoder.encode(contentMarkAsPaid),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            markedAsPaidParams["RDLCN"] = Data(jsonString.utf8).base64EncodedString()
        }

        return markedAsPaidParams
    }

    // swiftlint:enable non_optional_string_data_conversion
}
