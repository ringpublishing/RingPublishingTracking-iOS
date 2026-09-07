//
//  DecoratorTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 06/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class DecoratorTests: XCTestCase {

    // MARK: UniqueIdentifierDecorator Tests

    func testParameters_uniqueIdentifierDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let decorator = UniqueIdentifierDecorator()

        // Then
        let params1 = decorator.parameters
        XCTAssertEqual(params1["IP"], params1["IV"], "IP and IV parameters should be equal")

        // When
        decorator.updateSecondaryIdentifier()

        // Then
        let params2 = decorator.parameters
        XCTAssertNotEqual(params2["IP"], params2["IV"], "IP and IV parameters should be different")

        // When
        decorator.updateIdentifiers()

        // Then
        let params3 = decorator.parameters
        XCTAssertEqual(params3["IP"], params3["IV"], "IP and IV parameters should be equal")
        XCTAssertNotEqual(params1["IP"], params3["IP"], "Initial IP and new IP parameters should be different")
        XCTAssertNotEqual(params1["IV"], params3["IV"], "Initial IV and new IV parameters should be different")
    }

    func testParameters_uniqueIdentifierDecoratorCreated_returnedParametersHaveCorrectLength() {
        // Run this test multiple times as only sometimes identifiers could be generated wrong

        for _ in 0...100 {
            // Given
            let decorator = UniqueIdentifierDecorator()

            // When
            let ipParam = decorator.parameters["IP"] as? String ?? ""
            let ivParam = decorator.parameters["IV"] as? String ?? ""

            // Then
            XCTAssertEqual(ipParam.count, 24, "IP parameter should have 24 characters")
            XCTAssertEqual(ivParam.count, 24, "IV parameter should have 24 characters")
        }
    }

    // MARK: - SessionIdentifierDecorator Tests

    func testParameters_sessionIdentifierDecoratorCreated_returnedParameterHasCorrectLength() {
        for _ in 0...100 {
            // Given
            let decorator = SessionIdentifierDecorator()

            // When
            let isParam = decorator.parameters["IS"] as? String ?? ""

            // Then
            XCTAssertEqual(isParam.count, 24, "IS parameter should have 24 characters")
            XCTAssertTrue(isParam.allSatisfy(\.isNumber), "IS parameter should only contain digits")
        }
    }

    func testParameters_sessionIdentifierDecoratorCreated_valueStaysConstantUntilNewSessionStarted() {
        // Given
        let decorator = SessionIdentifierDecorator()
        let initialIsParam = decorator.parameters["IS"]

        // When
        decorator.startNewSession()

        // Then
        XCTAssertNotEqual(initialIsParam, decorator.parameters["IS"], "IS should change after starting a new session")
    }

    func testParameters_twoSessionIdentifierDecoratorsCreated_returnedParametersAreDifferent() {
        // Given
        let decorator1 = SessionIdentifierDecorator()
        Thread.sleep(forTimeInterval: 1)
        let decorator2 = SessionIdentifierDecorator()

        // Then
        XCTAssertNotEqual(decorator1.parameters["IS"], decorator2.parameters["IS"],
                           "IS should be different for two separate decorator instances")
    }

    // MARK: - SequenceDecorator Tests

    func testParameters_sequenceDecoratorEventDecoratedCalled_valueIncrementsPerCall() {
        // Given
        let decorator = SequenceDecorator()

        // Then
        XCTAssertEqual(decorator.parameters["SQ"], 0, "First SQ value should be 0")

        // When
        decorator.eventDecorated()

        // Then
        XCTAssertEqual(decorator.parameters["SQ"], 1, "SQ should increment by 1 after eventDecorated() call")

        // When
        decorator.eventDecorated()

        // Then
        XCTAssertEqual(decorator.parameters["SQ"], 2, "SQ should increment by 1 after eventDecorated() call")
    }

    func testParameters_sequenceDecoratorEventDecoratedNotCalled_valueStaysConstant() {
        // Given
        let decorator = SequenceDecorator()

        // Then
        XCTAssertEqual(decorator.parameters["SQ"], 0, "SQ should not change without calling eventDecorated()")
        XCTAssertEqual(decorator.parameters["SQ"], 0, "SQ should not change without calling eventDecorated()")
    }

    func testParameters_sequenceDecoratorReachedMaxValue_valueWrapsToZero() {
        // Given
        let decorator = SequenceDecorator(sequence: Int.max)

        // When
        decorator.eventDecorated()

        // Then
        XCTAssertEqual(decorator.parameters["SQ"], 0, "SQ should wrap to 0 after reaching Int.max")
    }


    // MARK: - SizeDecorator Tests

    func testParameters_sizeDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let provider = SizeProviderStub()
        let decorator = SizeDecorator(sizeProvider: provider)

        // Then
        let params = decorator.parameters
        let csField = params["CS"]
        let cwField = params["CW"]

        XCTAssertEqual(csField,
                       "\(Int(provider.screenSize.width))x\(Int(provider.screenSize.height))x24",
                       "CS should be equal to given size")
        XCTAssertEqual(cwField,
                       "\(Int(provider.applicationSize.width))x\(Int(provider.applicationSize.height))",
                       "CW should be equal to given size")
    }

    // MARK: - StructureInfoDecorator Tests

    func testParameters_structureInfoDecoratorCreated_returnedParametersAreCorrect() throws {
        // Given
        let applicationRootPath = "Onet"
        let applicationDefaultStructurePath  = ["home"]
        let sampleArticleURL = try XCTUnwrap(URL(string: "https://test.com/article?id=123"))

        let decorator = StructureInfoDecorator()

        // When
        decorator.updateApplicationRootPath(applicationRootPath: applicationRootPath)
        decorator.updateStructureType(structureType: .structurePath(applicationDefaultStructurePath), contentPageViewSource: nil)

        // Then
        let params1 = decorator.parameters

        XCTAssertEqual(params1["DV"], "onet_app_ios/home", "DV should be correct")
        XCTAssertEqual(params1["DU"], "https://onet.app.ios/home", "DU should be correct")
        XCTAssertNil(params1["DR"], "DR should be nil")

        // When
        decorator.updateStructureType(structureType: .publicationUrl(sampleArticleURL, ["home", "sport", "article_123"]),
                                      contentPageViewSource: .default)

        // Then
        let params2 = decorator.parameters

        XCTAssertEqual(params2["DV"], "onet_app_ios/home/sport/article_123", "DV should be correct")
        XCTAssertEqual(params2["DU"], sampleArticleURL.absoluteString, "DU should be correct")
        XCTAssertEqual(params2["DR"], params1["DU"], "DR should be nil")
    }

    func testParameters_structureInfoDecoratorCreatedForContentPageView_returnedParametersAreCorrect() {
        // Given
        let applicationRootPath = "Onet"
        let applicationDefaultStructurePath  = ["home"]
        let sampleArticleURL = URL(string: "https://test.com/article?id=123")! // swiftlint:disable:this force_unwrapping

        let decorator = StructureInfoDecorator()

        // When
        decorator.updateApplicationRootPath(applicationRootPath: applicationRootPath)
        decorator.updateStructureType(structureType: .structurePath(applicationDefaultStructurePath), contentPageViewSource: nil)

        // Then
        let params1 = decorator.parameters

        XCTAssertEqual(params1["DV"], "onet_app_ios/home", "DV should be correct")
        XCTAssertEqual(params1["DU"], "https://onet.app.ios/home", "DU should be correct")
        XCTAssertNil(params1["DR"], "DR should be nil")

        // When
        decorator.updateStructureType(structureType: .publicationUrl(sampleArticleURL, ["home", "sport", "article_123"]),
                                      contentPageViewSource: .socialMedia)

        // Then
        let params2 = decorator.parameters

        XCTAssertEqual(params2["DV"], "onet_app_ios/home/sport/article_123", "DV should be correct")
        XCTAssertEqual(params2["DU"], sampleArticleURL.absoluteString + "?utm_medium=social", "DU should be correct")
        XCTAssertEqual(params2["DR"], params1["DU"], "DR should be equal to previous DU")

        // When
        decorator.updateStructureType(structureType: .publicationUrl(sampleArticleURL, ["home", "sport", "article_123"]),
                                      contentPageViewSource: .pushNotifcation)

        // Then
        let params3 = decorator.parameters

        XCTAssertEqual(params3["DV"], "onet_app_ios/home/sport/article_123", "DV should be correct")
        XCTAssertEqual(params3["DU"], sampleArticleURL.absoluteString + "?utm_medium=push", "DU should be correct")
        XCTAssertEqual(params3["DR"], params2["DU"], "DR should be equal to previous DU")
    }

    // MARK: - AdAreaDecorator Tests

    func testParameters_adAreaDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let decorator = AdAreaDecorator()
        let applicationDefaultAdvertisementArea = "TestAdvertisementArea"

        // Then
        decorator.updateApplicationAdvertisementArea(applicationAdvertisementArea: applicationDefaultAdvertisementArea)
        let params = decorator.parameters

        XCTAssertEqual(params["DA"], applicationDefaultAdvertisementArea, "DA should be correct")
    }

    // MARK: - UserDataDecorator Tests

    func testParameters_userDataDecoratorCreated_returnedParametersAreMatching() {
        // Given
        let artemisExternal = ArtemisExternal(
            model: "202010190919497238108361",
            models: [
                "ats_ri": AnyCodable("202010190919497238108361")
            ]
        )
        let artemisID = ArtemisID(artemis: "202010190919497238108361", external: artemisExternal)
        let decorator = UserDataDecorator()

        // Then
        decorator.updateArtemisData(artemis: artemisID)
        let params = decorator.parameters

        // swiftlint:disable line_length
        let expectedBase64 = "eyJpZCI6eyJhcnRlbWlzIjoiMjAyMDEwMTkwOTE5NDk3MjM4MTA4MzYxIiwiZXh0ZXJuYWwiOnsibW9kZWwiOiIyMDIwMTAxOTA5MTk0OTcyMzgxMDgzNjEiLCJtb2RlbHMiOnsiYXRzX3JpIjoiMjAyMDEwMTkwOTE5NDk3MjM4MTA4MzYxIn19fX0="
        // swiftlint:enable line_length
        XCTAssertEqual(params["RDLU"], expectedBase64)
        XCTAssertNil(params["IZ"], "IZ should be empty")
    }

    func testParameters_userDataDecoratorCreatedForNonOKontoSSO_returnedParametersAreCorrect() {
        // Given
        let userId = "12345"
        let email = "test@email.com"
        let decorator = UserDataDecorator()

        // Then
        decorator.updateUserData(userId: userId, email: email)
        decorator.updateSSO(ssoSystemName: "Test")
        let params = decorator.parameters

        let expectedBase64 = """
        eyJzc28iOnsibG9nZ2VkIjp7ImlkIjoiMTIzNDUiLCJtZDUiOiI5Mzk0MmU5NmY1YWNkODNlMmUwNDdhZDhmZTAzMTE0ZCJ9LCJuYW1lIjoiVGVzdCJ9fQ==
        """

        XCTAssertEqual(params["RDLU"], expectedBase64, "RDLU should match")
        XCTAssertTrue(params["IZ"] == nil, "IZ should be empty for SSO system name not equal to O!Konto")
    }

    func testParameters_userDataDecoratorCreatedForOKontoSSO_returnedParametersAreCorrect() {
        // Given
        let userId = "12345"
        let email = "test@email.com"
        let decorator = UserDataDecorator()

        // Then
        decorator.updateUserData(userId: userId, email: email)
        decorator.updateSSO(ssoSystemName: "O!Konto")
        let params = decorator.parameters

        let expectedBase64 = """
        eyJzc28iOnsibG9nZ2VkIjp7ImlkIjoiMTIzNDUiLCJtZDUiOiI5Mzk0MmU5NmY1YWNkODNlMmUwNDdhZDhmZTAzMTE0ZCJ9LCJuYW1lIjoiTyFLb250byJ9fQ==
        """

        XCTAssertEqual(params["RDLU"], expectedBase64, "RDLU should match")
        XCTAssertEqual(params["IZ"], userId, "IZ should match")
    }

    func testParameters_userDataDecoratorCreatedAndUsedLoggedOut_parametersAreEmpty() {
        // Given
        let decorator = UserDataDecorator()

        // Then
        decorator.updateUserData(userId: nil, email: nil)
        decorator.updateSSO(ssoSystemName: "Test")

        let params = decorator.parameters

        let rdluData = """
        eyJzc28iOnsibG9nZ2VkIjp7fSwibmFtZSI6IlRlc3QifX0=
        """

        XCTAssertEqual(params["RDLU"], rdluData)
        XCTAssertNil(params["IZ"], "IZ should be empty")
    }

    func testParameters_userDataDecoratorCreatedWithActiveSubscription_subscriptionIsPresent() {

        let decorator = UserDataDecorator()

        decorator.updateUserData(userId: "12345", email: "test@email.com")
        decorator.updateSSO(ssoSystemName: "Test")
        decorator.updateActiveSubscriber(true)

        let params = decorator.parameters

        // swiftlint:disable line_length
        let rdluData = """
        eyJzc28iOnsibG9nZ2VkIjp7ImlkIjoiMTIzNDUiLCJtZDUiOiI5Mzk0MmU5NmY1YWNkODNlMmUwNDdhZDhmZTAzMTE0ZCJ9LCJuYW1lIjoiVGVzdCJ9LCJ0eXBlIjoic3Vic2NyaWJlciJ9
        """
        // swiftlint:enable line_length

        XCTAssertEqual(params["RDLU"], rdluData)
    }

    func testParameters_userDataDecoratorCreatedWithInactiveSubscription_subscriptionIsNotPresent() {

        let decorator = UserDataDecorator()

        decorator.updateUserData(userId: "12345", email: "test@email.com")
        decorator.updateSSO(ssoSystemName: "Test")
        decorator.updateActiveSubscriber(true)
        decorator.updateActiveSubscriber(false)

        let params = decorator.parameters

        let rdluData = """
        eyJzc28iOnsibG9nZ2VkIjp7ImlkIjoiMTIzNDUiLCJtZDUiOiI5Mzk0MmU5NmY1YWNkODNlMmUwNDdhZDhmZTAzMTE0ZCJ9LCJuYW1lIjoiVGVzdCJ9fQ==
        """

        XCTAssertEqual(params["RDLU"], rdluData)
    }

    // MARK: - TenantIdentifierDecorator Tests

    func testParameters_tenantIdentifierDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let decorator = TenantIdentifierDecorator()
        let tenantId = "12345678"

        // Then
        decorator.updateTenantId(tenantId: tenantId)
        let params = decorator.parameters

        XCTAssertEqual(params["TID"], tenantId, "TID should be correct")
    }

    // MARK: - ClientDecorator Tests

    func testParameters_clientDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let decorator = ClientDecorator()

        // Then
        let params = decorator.parameters

        XCTAssertEqual(params["RDLC"], "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAifX0=", "RDLC should be correct")
    }

    func testParameters_clientDecoratorUpdatedWithValidVariantExternalParameters_rdlcContainsVariant() {
        // Given
        let decorator = ClientDecorator()

        // When
        decorator.updateVariantExternalParameters(["api_ver": "1.0.1b"])
        let params = decorator.parameters

        // Then
        // swiftlint:disable line_length
        let expectedBase64 = "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAifSwidmFyaWFudCI6eyJleHRlcm5hbCI6eyJhcGlfdmVyIjoiMS4wLjFiIn19fQ=="
        // swiftlint:enable line_length
        XCTAssertEqual(params["RDLC"], expectedBase64, "RDLC should contain variant.external")
    }

    func testParameters_clientDecoratorUpdatedWithTooManyVariantExternalKeys_parametersAreRejected() {
        // Given
        let decorator = ClientDecorator()
        let tooManyKeys = Dictionary(uniqueKeysWithValues: (0..<11).map { ("k\($0)", "v") })

        // When
        decorator.updateVariantExternalParameters(tooManyKeys)
        let params = decorator.parameters

        // Then
        XCTAssertEqual(params["RDLC"], "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAifX0=", "RDLC should not contain rejected variant.external")
    }

    func testParameters_clientDecoratorUpdatedWithTooLongVariantExternalKeyOrValue_parametersAreRejected() {
        // Given
        let decorator = ClientDecorator()

        // When / Then
        decorator.updateVariantExternalParameters(["a_key_too_long_here": "v"])
        XCTAssertEqual(decorator.parameters["RDLC"], "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAifX0=", "RDLC should reject too long key")

        decorator.updateVariantExternalParameters(["k": "a_value_too_long_here"])
        XCTAssertEqual(decorator.parameters["RDLC"], "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAifX0=", "RDLC should reject too long value")
    }

    func testClientData_viewTypeProvided_returnedClientDataContainsViewType() {
        // Given
        let decorator = ClientDecorator()

        // When / Then
        XCTAssertEqual(decorator.clientData(viewType: .text),
                       "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAiLCJ2aWV3VHlwZSI6InRleHQifX0=",
                       "Client data should contain text view type")

        XCTAssertEqual(decorator.clientData(viewType: .tts),
                       "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAiLCJ2aWV3VHlwZSI6InR0cyJ9fQ==",
                       "Client data should contain tts view type")

        XCTAssertEqual(decorator.clientData(viewType: .smartshort),
                       "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAiLCJ2aWV3VHlwZSI6InNtYXJ0c2hvcnQifX0=",
                       "Client data should contain smart short view type")
    }

    func testClientData_viewTypeProvidedAndVariantExternalParametersSet_returnedClientDataContainsBoth() {
        // Given
        let decorator = ClientDecorator()

        // When
        decorator.updateVariantExternalParameters(["api_ver": "1.0.1b"])

        // Then
        // swiftlint:disable:next line_length
        let expectedBase64 = "eyJjbGllbnQiOnsidHlwZSI6Im5hdGl2ZV9hcHAiLCJ2aWV3VHlwZSI6InRleHQifSwidmFyaWFudCI6eyJleHRlcm5hbCI6eyJhcGlfdmVyIjoiMS4wLjFiIn19fQ=="
        XCTAssertEqual(decorator.clientData(viewType: .text), expectedBase64, "Client data should contain view type and variant.external")
    }
}
