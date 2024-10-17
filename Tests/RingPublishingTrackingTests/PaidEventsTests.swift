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
            subscriptionBasePrice: 100.0,
            subscriptionPromoPrice: 99.99,
            subscriptionPromoDuration: "1w",
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
        XCTAssertEqual(event.eventParameters["supplier_app_id"], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters["paywall_supplier"], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters["paywall_template_id"], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters["paywall_variant_id"], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters["source"], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters["source_publication_uuid"], sampleContentMetadata.contentId)
        XCTAssertEqual(event.eventParameters["source_dx"], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters["closure_percentage"], sampleOfferContextData.closurePercentage)
        XCTAssertEqual(event.eventParameters["tpcc"], sampleTpcc)
        XCTAssertEqual(event.eventParameters["RDLCN"], mockRdlcnEncodingPaid())
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
        XCTAssertEqual(event.eventParameters["supplier_app_id"], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters["paywall_supplier"], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters["paywall_template_id"], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters["paywall_variant_id"], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters["source"], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters["source_publication_uuid"], sampleContentMetadata.contentId)
        XCTAssertEqual(event.eventParameters["source_dx"], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters["closure_percentage"], sampleOfferContextData.closurePercentage)
        XCTAssertEqual(event.eventParameters["tpcc"], sampleTpcc)
        XCTAssertEqual(event.eventParameters["RDLCN"], mockRdlcnEncodingPaid())
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
        XCTAssertEqual(event.eventParameters["supplier_app_id"], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters["paywall_supplier"], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters["paywall_template_id"], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters["paywall_variant_id"], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters["source"], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters["source_publication_uuid"], sampleContentMetadata.contentId)
        XCTAssertEqual(event.eventParameters["source_dx"], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters["closure_percentage"], nil)
        XCTAssertEqual(event.eventParameters["tpcc"], sampleTpcc)
        XCTAssertEqual(event.eventParameters["term_id"], sampleTermId)
        XCTAssertEqual(event.eventParameters["RDLCN"], mockRdlcnEncodingPaid())
    }

    func testPaidEvent_createPurchaseEvent_properParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleTpcc = "hard_xmass_promoInline"
        let sampleTermId = "TMEVT00KVHV0"
        let sampleFakeUserId = "fake_001"
        let sampleTermConversionId = "TCCJTS9X87VB"
        let paymentMethod = "app_store"
        let sampleEventDetails = """
        {
            "fake_user_id": "fake_001",
            "subscription_base_price": 100,
            "subscription_price_currency": "usd",
            "subscription_promo_duration": "1w",
            "subscription_promo_price": 99.99
        }
        """.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)

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

        // Then
        XCTAssertTrue(!event.eventParameters.isEmpty)
        XCTAssertEqual(event.eventParameters["supplier_app_id"], sampleOfferData.supplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters["paywall_supplier"], sampleOfferData.supplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters["paywall_template_id"], sampleOfferData.paywallTemplateId)
        XCTAssertEqual(event.eventParameters["paywall_variant_id"], sampleOfferData.paywallVariantId)
        XCTAssertEqual(event.eventParameters["source"], sampleOfferContextData.source)
        XCTAssertEqual(event.eventParameters["source_publication_uuid"], sampleContentMetadata.contentId)
        XCTAssertEqual(event.eventParameters["source_dx"], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters["closure_percentage"], nil)
        XCTAssertEqual(event.eventParameters["tpcc"], sampleTpcc)
        XCTAssertEqual(event.eventParameters["term_id"], sampleTermId)
        XCTAssertEqual(event.eventParameters["term_conversion_id"], sampleTermConversionId)
        XCTAssertEqual(event.eventParameters["RDLCN"], mockRdlcnEncodingPaid())
        XCTAssertEqual(event.eventParameters["event_details"], sampleEventDetails)
        XCTAssertEqual(event.eventParameters["payment_method"], paymentMethod)
    }

    func testPaidEvent_createShowMetricLimitEvent_properParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()

        // When
        let event = eventsFactory.createShowMetricLimitEvent(
            contentMetadata: sampleContentMetadata,
            supplierData: sampleSupplierData,
            metricsData: sampleMetricsData
        )

        // Then
        XCTAssertTrue(!event.eventParameters.isEmpty)
        XCTAssertEqual(event.eventParameters["metric_limit_name"], sampleMetricsData.metricLimitName)
        XCTAssertEqual(event.eventParameters["free_pv_cnt"], sampleMetricsData.freePageViewCount)
        XCTAssertEqual(event.eventParameters["free_pv_limit"], sampleMetricsData.freePageViewLimit)
        XCTAssertEqual(event.eventParameters["supplier_app_id"], sampleSupplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters["paywall_supplier"], sampleSupplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters["source_publication_uuid"], sampleContentMetadata.contentId)
        XCTAssertEqual(event.eventParameters["source_dx"], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters["RDLCN"], mockRdlcnEncodingPaid())
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
        XCTAssertEqual(event.eventParameters["supplier_app_id"], sampleSupplierData.supplierAppId)
        XCTAssertEqual(event.eventParameters["paywall_supplier"], sampleSupplierData.paywallSupplier)
        XCTAssertEqual(event.eventParameters["source_publication_uuid"], sampleContentMetadata.contentId)
        XCTAssertEqual(event.eventParameters["source_dx"], sampleContentMetadata.dxParameter)
        XCTAssertEqual(event.eventParameters["event_details"], sampleLikelihoodJson)
        XCTAssertEqual(event.eventParameters["RDLCN"], mockRdlcnEncodingPaid())
    }

    func testPaidEvent_createMobileAppFakeUserIdReplacedEvent_properParametersInEvent() {
        // Given
        let eventsFactory = EventsFactory()
        let sampleFakeUserId = "fake_001"
        let sampleRealUserId = "real_001"
        let sampleUserJson = "{\"fake_user_id\":\"\(sampleFakeUserId)\",\"real_user_id\":\"\(sampleRealUserId)\"}"

        // When
        let event = eventsFactory.createMobileAppFakeUserIdReplacedEvent(
            temporaryUserId: sampleFakeUserId,
            realUserId: sampleRealUserId
        )

        // Then
        XCTAssertTrue(!event.eventParameters.isEmpty)
        XCTAssertEqual(event.eventParameters["event_details"], sampleUserJson)
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
