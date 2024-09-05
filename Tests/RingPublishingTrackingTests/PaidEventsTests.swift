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

    func testCreatePaidEvent_createShowOfferEvent_parametersInEvent() {
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

    func testPaidEvent_createShowOfferEvent_properParametersInEvent() {
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

    func testPaidEvent_createShowOfferTeaserEvent_properParametersInEvent() {
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

    func testPaidEvent_createPurchaseClickButtonEvent_properParametersInEvent() {
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

    func testPaidEvent_createPurchaseEvent_properParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleTpcc = "hard_xmass_promoInline"
        let sampleTermId = "TMEVT00KVHV0"
        let sampleFakeUserId = "fake_001"
        let sampleTermConversionId = "TCCJTS9X87VB"
        let sampleFakeUserJson = "{\"fake_user_id\":\"\(sampleFakeUserId)\"}"

        // When
        let event = eventsFactory.createPurchaseEvent(
            contentMetadata: sampleContentMetadata,
            offerData: sampleOfferData,
            offerContextData: OfferContextData(source: sampleOfferContextData.source, closurePercentage: nil),
            subscriptionPaymentData: sampleSubscriptionPaymentData,
            termId: sampleTermId,
            termConversionId: sampleTermConversionId,
            targetPromotionCampaignCode: sampleTpcc,
            temporaryUserId: sampleFakeUserId
        )

        // swiftlint:disable line_length

        // Then
        XCTAssertTrue(!event.eventParameters.isEmpty)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.supplierAppId.rawValue], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallSupplier.rawValue], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallTemplateId.rawValue], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallVariantId.rawValue], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.source.rawValue], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourcePublicationUuid.rawValue], sampleContentMetadata.publicationId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourceDx.rawValue], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.closurePercentage.rawValue], nil)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.subscriptionBasePrice.rawValue], sampleSubscriptionPaymentData.subscriptionBasePrice)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.subscriptionPromoPrice.rawValue], sampleSubscriptionPaymentData.subscriptionPromoPrice)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.subscriptionPromoPriceDuration.rawValue], sampleSubscriptionPaymentData.subscriptionPromoPriceDuration)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.subscriptionPriceCurrency.rawValue], sampleSubscriptionPaymentData.subscriptionPriceCurrency)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paymentMethod.rawValue], sampleSubscriptionPaymentData.paymentMethod.rawValue)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.tpcc.rawValue], sampleTpcc)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.termId.rawValue], sampleTermId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.termConversionId.rawValue], sampleTermConversionId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.eventDetails.rawValue], sampleFakeUserJson)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.contentMarkedAsPaid.rawValue], mockRdlcnEncodingPaid())

        // swiftlint:enable line_length
    }

    func testPaidEvent_createShowMetricLimitEvent_properParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()

        // When
        let event = eventsFactory.createShowMetricLimitEvent(contentMetadata: sampleContentMetadata,
                                                             supplierData: sampleSupplierData,
                                                             metricsData: sampleMetricsData)

        // Then
        XCTAssertTrue(!event.eventParameters.isEmpty)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.metricLimitName.rawValue], sampleMetricsData.metricLimitName)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.freePvCnt.rawValue], sampleMetricsData.freePageViewCount)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.freePvLimit.rawValue], sampleMetricsData.freePageViewLimit)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.supplierAppId.rawValue], sampleSupplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallSupplier.rawValue], sampleSupplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourcePublicationUuid.rawValue], sampleContentMetadata.publicationId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourceDx.rawValue], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.contentMarkedAsPaid.rawValue], mockRdlcnEncodingPaid())
    }

    func testPaidEvent_createLikelihoodScoringEvent_properParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleLikelihoodJson = "{\"ltc\":\(sampleLikelihoodData.likelihoodToCancel ?? 0)," +
                                    "\"lts\":\(sampleLikelihoodData.likelihoodToSubscribe ?? 0)}"

        // When
        let event = eventsFactory.createLikelihoodScoringEvent(
            contentMetadata: sampleContentMetadata,
            supplierData: sampleSupplierData,
            likelihoodData: sampleLikelihoodData
        )

        // Then
        XCTAssertTrue(!event.eventParameters.isEmpty)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.supplierAppId.rawValue], sampleSupplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.paywallSupplier.rawValue], sampleSupplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourcePublicationUuid.rawValue], sampleContentMetadata.publicationId)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.sourceDx.rawValue], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.eventDetails.rawValue], sampleLikelihoodJson)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.contentMarkedAsPaid.rawValue], mockRdlcnEncodingPaid())
    }

    func testPaidEvent_createMobileAppFakeUserIdReplacedEvent_properParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleFakeUserId = "fake_001"
        let sampleRealUserId = "real_001"
        let sampleUserJson = "{\"fake_user_id\":\"\(sampleFakeUserId)\",\"real_user_id\":\"\(sampleRealUserId)\"}"

        // When
        let event = eventsFactory.createMobileAppFakeUserIdReplacedEvent(
            contentMetadata: sampleContentMetadata,
            temporaryUserId: sampleFakeUserId,
            realUserId: sampleRealUserId
        )

        // Then
        XCTAssertTrue(!event.eventParameters.isEmpty)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.eventDetails.rawValue], sampleUserJson)
        XCTAssertEqual(event.eventParameters[PaidEventParameter.contentMarkedAsPaid.rawValue], mockRdlcnEncodingPaid())
    }

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
