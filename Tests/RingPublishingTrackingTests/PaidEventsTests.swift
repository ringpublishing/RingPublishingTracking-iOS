//
//  PaidEventsTests.swift
//  RingPublishingTrackingTests
//
//  Created by Bernard Bijoch on 05/09/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import XCTest

class PaidEventsFactoryTests: XCTestCase {

    // swiftlint:disable implicitly_unwrapped_optional

    private var sampleSupplierData: SupplierData!
    private var sampleOfferData: OfferData!
    private var sampleOfferContextData: OfferContextData!
    private var sampleSubscriptionPaymentData: SubscriptionPaymentData!
    private var sampleMetricsData: MetricsData!
    private var sampleLikelihoodData: LikelihoodData!
    private var sampleContentMetadata: ContentMetadata!

    // swiftlint:enable implicitly_unwrapped_optional

    override func setUp() {
        super.setUp()

        sampleSupplierData = SupplierData(
            supplierAppId: "GTccriLYpe",
            paywallSupplier: "piano"
        )

        sampleOfferData = OfferData(
            supplierData: sampleSupplierData,
            paywallTemplateId: "OTT8ICJL3LWX",
            paywallVariantId: "OTVAEW37T5NG3",
            displayMode: .inline
        )

        sampleOfferContextData = OfferContextData(
            source: "closedArticle",
            closurePercentage: 50
        )

        sampleSubscriptionPaymentData = SubscriptionPaymentData(
            subscriptionBasePrice: "100",
            subscriptionPromoPrice: "99.99",
            subscriptionPromoPriceDuration: "1w",
            subscriptionPriceCurrency: "usd",
            paymentMethod: .appStore
        )

        sampleMetricsData = MetricsData(
            metricLimitName: "OnetMeter",
            freePageViewCount: 9,
            freePageViewLimit: 10
        )

        sampleLikelihoodData = LikelihoodData(
            likelihoodToSubscribe: 5,
            likelihoodToCancel: 4
        )

        sampleContentMetadata = ContentMetadata(
            publicationId: "publicationId",
            publicationUrl: URL(string: "https://domain.com")!, // swiftlint:disable:this force_unwrapping
            sourceSystemName: "source System_Name",
            contentPartIndex: 1,
            paidContent: true,
            contentId: "my-unique-content-id-1234"
        )
    }

    // Test 1: createPaidEvent_StringParameters_ThenParametersInEvent
    func testCreatePaidEvent_StringParameters_ThenParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()

        // When
        let event = eventsFactory.createShowOfferEvent(
            contentMetadata: sampleContentMetadata,
            offerData: sampleOfferData,
            offerContextData: sampleOfferContextData,
            targetPromotionCampaignCode: "hard_xmass_promoInline"
        )

        // Then
        XCTAssertFalse(event.eventParameters.isEmpty, "Event parameters should not be empty")
    }

    // Test 2: createShowOfferEvent_ThenProperParametersInEvent
    func testCreateShowOfferEvent_ThenProperParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleTpcc = "hard_xmass_promoInline"

        // When
        let event = eventsFactory.createShowOfferEvent(
            contentMetadata: sampleContentMetadata,
            offerData: sampleOfferData,
            offerContextData: sampleOfferContextData,
            targetPromotionCampaignCode: sampleTpcc
        )

        // Then
        XCTAssertEqual(event.eventParameters[PaidEventParameter.supplierAppId.rawValue], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallSupplier.rawValue], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallTemplateId.rawValue], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallVariantId.rawValue], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.source.rawValue], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourcePublicationUuid.rawValue], sampleContentMetadata.publicationId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourceDx.rawValue], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.closurePercentage.rawValue], sampleOfferContextData.closurePercentage)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.tpcc.rawValue], sampleTpcc)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.contentMarkedAsPaid.rawValue], mockRdlcnEncodingPaid())
    }

    // Test 3: createShowOfferTeaserEvent_ThenProperParametersInEvent
    func testCreateShowOfferTeaserEvent_ThenProperParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleTpcc = "hard_xmass_promoInline"

        // When
        let event = eventsFactory.createShowOfferTeaserEvent(
            contentMetadata: sampleContentMetadata,
            offerData: sampleOfferData,
            offerContextData: sampleOfferContextData,
            targetPromotionCampaignCode: sampleTpcc
        )

        // Then
        XCTAssertEqual(event.eventParameters[PaidEventParameter.supplierAppId.rawValue], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallSupplier.rawValue], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallTemplateId.rawValue], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallVariantId.rawValue], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.source.rawValue], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourcePublicationUuid.rawValue], sampleContentMetadata.publicationId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourceDx.rawValue], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.closurePercentage.rawValue], sampleOfferContextData.closurePercentage)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.tpcc.rawValue], sampleTpcc)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.contentMarkedAsPaid.rawValue], mockRdlcnEncodingPaid())
    }

    // Test 4: createPurchaseClickButtonEvent_ThenProperParametersInEvent
    func testCreatePurchaseClickButtonEvent_ThenProperParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleTpcc = "hard_xmass_promoInline"
        let sampleTermId = "TMEVT00KVHV0"
        let sampleOfferContextData = OfferContextData(source: sampleOfferContextData.source, closurePercentage: nil)

        // When
        let event = eventsFactory.createPurchaseClickButtonEvent(
            contentMetadata: sampleContentMetadata,
            offerData: sampleOfferData,
            offerContextData: sampleOfferContextData,
            termId: sampleTermId,
            targetPromotionCampaignCode: sampleTpcc
        )

        // Then
        XCTAssertEqual(event.eventParameters[PaidEventParameter.supplierAppId.rawValue], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallSupplier.rawValue], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallTemplateId.rawValue], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallVariantId.rawValue], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.source.rawValue], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourcePublicationUuid.rawValue], sampleContentMetadata.publicationId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourceDx.rawValue], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.closurePercentage.rawValue], nil)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.tpcc.rawValue], sampleTpcc)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.termId.rawValue], sampleTermId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.contentMarkedAsPaid.rawValue], mockRdlcnEncodingPaid())
    }

    // Continue converting other tests similarly...

    // Utility function
    private func mockRdlcnEncodingPaid() -> String {
        let input = "{\"publication\":{\"premium\":\(sampleContentMetadata.paidContent)},\"source\":{\"id\":" +
        "\"\(sampleContentMetadata.contentId)\",\"system\":\"\(sampleContentMetadata.sourceSystemName)\"}}"
        return encode(input: input)
    }

    private func encode(input: String) -> String {
        return Data(input.utf8).base64EncodedString(options: .endLineWithLineFeed)
    }
}
