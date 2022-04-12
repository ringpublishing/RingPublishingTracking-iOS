//
//  DecoratorTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 06/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class DecoratorTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

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

    func testParameters_structureInfoDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let applicationRootPath = "Onet"
        let applicationDefaultStructurePath  = ["Home"]
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
        let applicationDefaultStructurePath  = ["Home"]
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

    // MARK: - ConsentStringDecorator Tests

    func testParameters_consentStringDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let provider = ConsentProviderStub()
        let decorator = ConsentStringDecorator(consentProvider: provider)

        // Then
        let params = decorator.parameters

        XCTAssertEqual(params["_adpc"], provider.adpc, "_adpc should be correct")
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

    func testParameters_userDataDecoratorCreated_returnedParametersAreCorrect() {
        // Given
        let userId = "12345"
        let decorator = UserDataDecorator()
        let data = UserData(sso: .init(logged: .init(id: userId, md5: "5281143ec814ea2c66a4b1914a0135b7"), name: "Test"))

        // Then
        decorator.updateUserData(data: data)
        let params = decorator.parameters

        let expectedBase64 = """
        eyJzc28iOnsibmFtZSI6IlRlc3QiLCJsb2dnZWQiOnsiaWQiOiIxMjM0NSIsIm1kNSI6IjUyODExNDNlYzgxNGVhMmM2NmE0YjE5MTRhMDEzNWI3In19fQ==
        """

        XCTAssertEqual(params["RDLU"], expectedBase64, "RDLU should match")
        XCTAssertEqual(params["IZ"], userId, "IZ should match")
    }

    func testParameters_userDataDecoratorCreatedAndUsedLoggedOut_parametersAreEmpty() {
        // Given
        let decorator = UserDataDecorator()
        let data = UserData(sso: .init(logged: .init(id: "12345", md5: "5281143ec814ea2c66a4b1914a0135b7"), name: "Test"))
        let emptyData = UserData(sso: .init(logged: .init(id: nil, md5: nil), name: "Test"))

        // Then
        decorator.updateUserData(data: data)
        decorator.updateUserData(data: emptyData)

        let params = decorator.parameters

        XCTAssertNil(params["RDLU"], "RDLU should be empty")
        XCTAssertNil(params["IZ"], "IZ should be empty")
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
}
