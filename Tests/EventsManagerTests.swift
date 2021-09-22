//
//  EventsManagerTests.swift
//  AppTrackingTests
//
//  Created by Artur Rymarz on 21/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EventsManagerTests: XCTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testEventsManager_setEaUuidDateInNearFuture_theIdentifierIsValid() {
        // Given

        // Lifetime = 24h
        // Creation Date = 12 hours ago
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUuid(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)

        let storage = StaticStorage(eaUuid: eaUuid, trackingIds: nil, postInterval: nil)
        let manager = EventsManager(storage: storage)

        // Then
        XCTAssertTrue(manager.isEaUuidValid, "The identifier should be valid")
    }

    func testEventsManager_storeIds_storedIdsAreProperlyLoaded() {
        // Given
        let creationDate = Date().addingTimeInterval(TimeInterval(-60 * 60 * 12))
        let eaUuid = EaUuid(value: "1234567890", lifetime: 60 * 60 * 24, creationDate: creationDate)
        let storage = StaticStorage(eaUuid: eaUuid, trackingIds: [
            "key1": .init(value: "id1", lifetime: nil),
            "key2": .init(value: "id2", lifetime: nil),
            "key3": .init(value: "id3", lifetime: nil)
        ], postInterval: nil)
        let manager = EventsManager(storage: storage)

        // Then
        XCTAssertEqual(manager.storedIds().count, 4, "Stored ids number should be correct")
    }

    func testEventsManager_doNotSetEaUuid_theIdentifierIsInvalid() {
        // Given
        let storage = StaticStorage(eaUuid: nil, trackingIds: nil, postInterval: nil)
        let manager = EventsManager(storage: storage)

        // Then
        XCTAssertFalse(manager.isEaUuidValid, "The identifier should be invalid")
    }

    func testEventsManager_add5EventsToTheQueue_builtRequestContains5Events() {
        // Given
        let manager = EventsManager(storage: StaticStorage())

        // When
        manager.addEvents([
            Event.smallEvent(),
            Event.smallEvent(),
            Event.smallEvent(),
            Event.smallEvent(),
            Event.smallEvent()
        ])

        let request = manager.buildEventRequest()
        let events = request.events

        // Then
        XCTAssertEqual(events.count, 5, "Event request should contain proper number of events")
    }

    func testEventsManager_add1TooBigEventToTheQueue_builtRequestContains0Events() {
        // Given
        let manager = EventsManager(storage: StaticStorage())

        // When
        manager.addEvents([Event.tooBigEvent()])

        let request = manager.buildEventRequest()
        let events = request.events

        // Then
        XCTAssertEqual(events.count, 0, "Event request should contain proper number of events")
    }

    func testEventsManager_addEventsOverRequestBodySizeLimit_builtRequestBodySizeIsBelow1MB() {
        // Given
        let manager = EventsManager(storage: StaticStorage())

        let bodySizeLimit = Constants.requestBodySizeLimit
        let singleEventSize = Event.smallEvent().toReportedEvent().sizeInBytes

        // When
        let eventsAmount = Int(floor(Double(bodySizeLimit) / Double(singleEventSize))) + 1

        for _ in 0..<eventsAmount {
            manager.addEvents([Event.smallEvent()])
        }

        let request = manager.buildEventRequest()

        // Then
        XCTAssertLessThan(request.dictionary.jsonSizeInBytes,
                          bodySizeLimit,
                          "Event request body size should be below \(bodySizeLimit)")

        XCTAssertLessThan(request.events.count, eventsAmount, "Events above body size limit should not be added")
    }
}

private extension Event {
    func toReportedEvent() -> ReportedEvent {
        ReportedEvent(clientId: analyticsSystemName, eventType: eventName, data: eventParameters)
    }

    static func smallEvent() -> Self { // 190 bytes
        Event(eventParameters: [
            "key1": "value",
            "key2": "value",
            "key3": "value",
            "key4": "value",
            "key5": "value",
            "key6": "value",
            "key7": "value",
            "key8": "value",
            "key9": "value",
            "key10": "value"
        ])
    }

    // swiftlint:disable function_body_length
    static func tooBigEvent() -> Self { // over 16000 bytes
        Event(eventParameters: [
            // swiftlint:disable line_length
            "key": """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse facilisis felis nisl, vel porttitor sapien vulputate viverra. Integer condimentum, erat a semper maximus, leo orci vulputate nisl, et fermentum leo odio vitae mauris. Sed scelerisque, lorem ut interdum ornare, nisi eros faucibus neque, sed egestas quam tellus eget est. Curabitur fringilla nisi vel dui tincidunt viverra. Duis rutrum blandit sapien, eget fermentum lectus efficitur a. Cras pulvinar magna dui, sit amet placerat nisi vulputate sed. In tortor libero, imperdiet eget ex viverra, eleifend venenatis diam. Nam sit amet eros pellentesque, iaculis ligula nec, porta erat. Suspendisse pulvinar eleifend ullamcorper. Sed mollis ligula at sapien rutrum dapibus. Mauris tincidunt sagittis sagittis. Curabitur sed vehicula ligula.

Nulla vehicula, felis a rhoncus malesuada, nulla massa vestibulum magna, sit amet faucibus dolor velit vel purus. Duis ac justo et justo convallis efficitur. Morbi mi dolor, egestas ac viverra vitae, elementum a lacus. Mauris placerat tempus purus, nec malesuada metus cursus eu. In ac ornare dolor. Fusce sit amet libero et augue ullamcorper varius. Vivamus varius pulvinar efficitur. Sed laoreet egestas semper. Aenean accumsan velit sit amet risus congue condimentum. Sed condimentum ante nec massa auctor, a interdum nibh interdum.

Duis libero nunc, imperdiet sit amet condimentum sit amet, finibus vel augue. In aliquam dignissim ornare. Donec tempus finibus odio, fringilla pulvinar nulla elementum non. Donec vulputate convallis tortor, non ultrices ex lobortis vel. Morbi eu tellus lacinia, pharetra massa a, luctus sapien. Cras at consequat lorem, non interdum mi. Mauris eget odio ultrices, ultrices magna sit amet, sodales quam. Praesent bibendum vehicula turpis sed porta. Nunc ut vehicula magna, luctus sollicitudin nisi. Donec laoreet purus risus, in sollicitudin purus tincidunt sed.

Nulla ut mattis libero. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut vulputate porta magna, at porta lacus consectetur aliquam. Nunc laoreet tempor elit. Maecenas nunc lectus, pretium et pellentesque nec, lacinia a risus. Aliquam in hendrerit arcu. Aliquam porttitor nunc ut massa tempor facilisis.

Nunc vel purus mollis, molestie nunc quis, vestibulum risus. Nam luctus odio odio, eget tincidunt diam rhoncus id. Duis tempor ex et quam molestie, a convallis nisi mattis. Integer cursus laoreet risus, nec suscipit ipsum rhoncus id. Aenean egestas nunc purus, vel tincidunt metus tincidunt quis. Sed blandit interdum est, quis ultrices ex viverra eget. Nulla in nibh eget neque faucibus pellentesque aliquam nec nunc.

Fusce consectetur enim id hendrerit facilisis. Donec eu lectus neque. Maecenas at interdum tortor. Mauris faucibus semper dui. Integer imperdiet ut ante eu congue. Quisque a tincidunt mauris, ut condimentum lacus. Aenean at porta lectus. Quisque pulvinar, turpis sed suscipit euismod, mi dui eleifend metus, in rhoncus nulla ipsum a odio. Vivamus vitae risus congue, porttitor velit quis, luctus dui. Etiam ut congue enim. In eget leo orci.

Suspendisse facilisis arcu eu elit laoreet maximus. Integer ac orci nec mi congue consectetur. Mauris semper sem vitae ultrices pellentesque. Vivamus lobortis venenatis metus in hendrerit. Mauris id augue metus. Pellentesque accumsan turpis tortor, sit amet egestas tellus ullamcorper a. Vestibulum sit amet egestas dolor. Integer a elit tincidunt, porttitor felis et, pulvinar velit. Quisque eu turpis bibendum ligula tincidunt hendrerit. Praesent facilisis pharetra velit eget sodales. Mauris molestie ornare diam, quis interdum lectus consequat ac. Vivamus eget enim eu sem fermentum imperdiet id placerat dui. Pellentesque nisl tortor, efficitur quis tincidunt sed, scelerisque sed nulla.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam id imperdiet metus. Maecenas vulputate aliquam magna, et accumsan mauris consequat ac. Nulla ante tellus, suscipit vitae iaculis ut, laoreet ut nunc. Sed rhoncus varius lorem quis cursus. Sed tristique lectus eget pharetra aliquam. Interdum et malesuada fames ac ante ipsum primis in faucibus. Aenean a libero mi. Suspendisse id purus interdum, dignissim nunc id, venenatis lacus. Nam ornare eros dui, sit amet gravida dui sollicitudin ac. Sed ornare purus vitae volutpat convallis. Quisque cursus bibendum justo, ac tincidunt nibh aliquam at. Cras laoreet lacinia leo ac tempus. Nullam cursus lectus est, pretium bibendum ante maximus eget. Nulla facilisi. Fusce vel sollicitudin quam, non porttitor tellus.

Suspendisse tellus sapien, condimentum a mi non, efficitur accumsan sapien. Integer non lacinia ante. Suspendisse ante leo, tempor sollicitudin felis eget, tempor luctus nunc. Pellentesque lacinia dui ac dui facilisis, sed pharetra nisi pulvinar. Aenean at metus in tortor finibus interdum. Phasellus vel ultrices lectus. Etiam suscipit vehicula volutpat. Nulla enim est, viverra iaculis scelerisque eget, pretium vitae urna. Cras sagittis elit leo, dictum luctus est mollis eu. Nam finibus, enim non gravida auctor, mi elit accumsan nulla, a interdum tortor lorem nec elit.

Mauris at interdum leo, et luctus erat. Integer ac auctor lectus. Cras eu arcu ultrices, ornare dolor ac, commodo nulla. Morbi scelerisque nisi sed arcu imperdiet, non eleifend erat interdum. Phasellus nunc turpis, fermentum vel egestas id, posuere eget enim. Suspendisse commodo metus sollicitudin justo fermentum euismod. Cras volutpat ac risus vel ultrices. Nullam lacinia augue eu sem laoreet aliquam. Mauris eu tellus nec erat imperdiet posuere non nec magna. Integer pharetra ultrices sagittis. Cras sapien turpis, lobortis sed dui ac, ullamcorper rhoncus odio. Vestibulum at feugiat orci, in venenatis arcu. Nam ac placerat velit. Suspendisse rutrum elit sit amet est consectetur congue. Phasellus non accumsan sapien. Fusce rhoncus velit ac odio pharetra scelerisque.

Nunc sed quam mattis, tristique elit et, euismod urna. In efficitur ligula sit amet ipsum consectetur, ut tristique nunc rhoncus. Sed viverra odio ac urna mollis, nec malesuada mauris aliquam. Morbi sagittis ante vitae mi pharetra, vel lobortis dui congue. Nullam non velit nulla. Nullam et nibh facilisis, dictum ex ac, ullamcorper metus. Curabitur nunc urna, sollicitudin ut mi vel, faucibus interdum dolor. Fusce libero nisi, egestas sed diam eu, posuere dignissim urna. Aenean mattis enim eget nunc facilisis maximus. Aliquam erat volutpat.

Sed congue felis vestibulum, mattis massa eu, ornare justo. Fusce at velit sit amet dolor porttitor ullamcorper ac ut sapien. Nulla eu odio aliquam, aliquam turpis ac, ultricies nisi. Donec dapibus diam velit, id lobortis urna eleifend non. Donec laoreet porta velit, a luctus arcu facilisis non. Nam quis dapibus elit. Aliquam est urna, hendrerit interdum semper eu, gravida vitae sapien. Quisque congue arcu id elementum tempor. Aenean est diam, mollis sagittis sem eu, fringilla ullamcorper diam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Morbi enim mi, imperdiet eget libero eu, aliquam luctus tellus. Curabitur consequat velit a tristique lacinia. Nullam volutpat pulvinar accumsan.

Mauris eu pretium purus, sed luctus purus. Ut sed interdum odio. Nam volutpat faucibus lobortis. Nullam fringilla quis nulla ut sagittis. Etiam luctus eleifend consectetur. Nunc dolor felis, dapibus non mattis id, tincidunt mattis neque. Nulla eget augue sit amet nisl luctus volutpat eget sit amet ligula. Sed ac metus eleifend, viverra elit eget, bibendum ante. Integer hendrerit aliquet lectus, a aliquam orci gravida at. Donec tristique gravida dolor, non sodales metus tristique eu. Phasellus vitae ipsum volutpat, congue arcu eget, vulputate arcu. Phasellus dapibus a lacus nec eleifend. Fusce non dolor urna. In mattis aliquam nunc, a auctor arcu venenatis a. Curabitur vulputate lorem eget sem rutrum aliquam. Cras molestie, sapien sed blandit malesuada, arcu nunc semper lectus, ut ultricies mauris felis sed sem.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas a volutpat ex. Cras ut risus porta urna feugiat condimentum vitae at tellus. Fusce eu erat sit amet orci iaculis rutrum. Maecenas rutrum lectus non sagittis ullamcorper. Morbi tincidunt felis quis diam lacinia sollicitudin. Pellentesque turpis libero, blandit sit amet tortor gravida, congue eleifend nulla. Vestibulum condimentum massa sed ligula rutrum, et feugiat ligula eleifend. Aliquam viverra ullamcorper eros, sit amet sodales libero luctus sed. Vivamus congue mattis posuere. Pellentesque at sollicitudin ante, a molestie nunc. Sed vitae lacinia ante. Pellentesque augue lacus, finibus id dignissim vitae, scelerisque nec ligula. Quisque varius tristique ultricies. Cras dui velit, tincidunt sed efficitur sed, lobortis vel erat. Maecenas tempus odio quis leo euismod cursus.

Phasellus quis porttitor arcu. Morbi ut nibh ullamcorper, volutpat mauris non, fringilla elit. Ut in tortor a diam commodo sodales. Aliquam lobortis, ipsum eget congue laoreet, felis massa bibendum dolor, in pretium risus massa in diam. Nulla et nisl neque. Sed blandit vulputate ex, sed luctus mi laoreet vitae. Proin sapien ex, efficitur id rhoncus et, convallis a nisi. Ut condimentum fringilla felis, non dictum eros vestibulum id. Donec aliquet fermentum lorem, auctor gravida neque egestas id. Nam et turpis justo. Donec vel lorem at est cursus consectetur a et ligula. Sed tempor, leo dapibus varius vehicula, magna orci posuere est, ut aliquet elit felis sed leo. Nullam rutrum nisl posuere ipsum semper, et rutrum velit porttitor.

Ut lobortis neque vitae massa ultrices, vitae luctus enim interdum. Vivamus vel eleifend dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Vestibulum at ante et lacus mattis aliquam eget vel nulla. Fusce ut porttitor nibh, vitae scelerisque nisl. Nam orci mauris, tincidunt pharetra elementum vitae, mattis quis magna. Nulla facilisi.

Curabitur posuere molestie maximus. Aenean id ipsum mauris. Integer vitae pretium nisi. Ut sagittis orci felis. Nulla ac iaculis quam. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nullam ut orci lorem.

Duis scelerisque in quam sit amet pellentesque. Nulla ac vestibulum libero, ac vestibulum velit. Quisque facilisis dui in ullamcorper consequat. Vestibulum facilisis at ante ut accumsan. Sed in dapibus massa, quis malesuada velit. Duis dapibus felis at porttitor tincidunt. Nunc a suscipit turpis. Maecenas felis libero, ornare nec ligula quis, placerat mollis odio. Aenean facilisis lectus et metus faucibus suscipit. Duis blandit arcu quis libero fringilla eleifend.

Nulla at sem velit. Vivamus vehicula cursus euismod. Praesent ac diam id eros semper egestas. Praesent consequat pellentesque tristique. Donec id gravida quam, quis condimentum neque. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin blandit ante ut arcu hendrerit fringilla. Curabitur non varius metus.

Cras ante risus, rhoncus eget leo viverra, placerat congue ligula. Proin egestas arcu nulla. Cras pulvinar arcu ac egestas scelerisque. Donec odio neque, tempor ac eleifend sit amet, sodales non libero. In laoreet elit quis metus fermentum feugiat in vitae turpis. Nunc nec rhoncus neque. Mauris ac suscipit magna, sed venenatis nisi. Vestibulum vitae euismod urna, et mattis mi. Phasellus bibendum orci vel lobortis tempus. Proin rutrum porttitor ex quis porta. Curabitur interdum sagittis mattis. Nulla congue lectus a dignissim maximus. Suspendisse urna nulla, sagittis sodales arcu a, laoreet pharetra elit. Cras sit amet elit sit amet dui malesuada eleifend. Vestibulum dapibus metus a molestie egestas.

In molestie blandit consequat. Donec efficitur, augue et tincidunt vulputate, velit turpis volutpat velit, vitae ultrices est est eu elit. Donec ex mauris, volutpat in quam vel, ullamcorper eleifend purus. Duis et sapien maximus, facilisis odio vel, placerat odio. Vivamus fringilla ipsum ac velit interdum finibus. Donec non efficitur turpis. Ut ante urna, cursus quis sagittis in, facilisis a dui.

Donec vestibulum neque ac blandit scelerisque. Maecenas scelerisque posuere vulputate. Sed iaculis fringilla mauris, quis eleifend turpis venenatis a. Fusce sodales nibh ut ex bibendum, non sagittis nunc pellentesque. In ut porttitor ipsum. Ut sagittis sem lectus, vel venenatis ex hendrerit vel. Sed ultricies, arcu sollicitudin tincidunt posuere, nulla enim facilisis augue, in volutpat erat orci viverra ipsum. Maecenas sed elit enim. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas quis elementum arcu, sed congue est. Morbi vel euismod lacus, blandit blandit nulla. In ut sapien pellentesque, suscipit tellus id, ornare ipsum.

Vestibulum feugiat lacinia risus quis placerat. Nam eget iaculis erat. Donec eu porttitor nisi. Fusce hendrerit varius erat. Sed congue sapien vel sodales aliquet. Nunc semper diam erat, ac aliquam nisi eleifend nec. Curabitur hendrerit gravida tortor vitae consequat. Praesent sit amet ligula blandit, condimentum metus vitae, fermentum diam. Donec pretium maximus purus, dictum ornare est suscipit a. Donec ipsum urna, vulputate in sagittis pharetra, ullamcorper in mi. Aenean sed mi eget turpis feugiat egestas in a urna.

Curabitur ac quam laoreet, ullamcorper purus et, volutpat lectus. Curabitur turpis ipsum, eleifend nec mollis nec, vestibulum tincidunt lorem. Quisque accumsan sapien in laoreet laoreet. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nam varius mauris at sem euismod vehicula. Nulla ornare hendrerit ligula, at fermentum arcu suscipit vitae. Nulla at faucibus arcu. Aliquam erat volutpat. Nunc vel turpis sit amet neque ullamcorper vehicula. Suspendisse leo neque, cursus sit amet consequat eu, egestas in ipsum. Aliquam porta blandit posuere. Pellentesque finibus, eros sed feugiat mattis, massa lacus condimentum odio, sed gravida arcu tellus eget mauris. Pellentesque dolor eros, porta vitae nisl non, mattis imperdiet augue. Vivamus iaculis, orci sed placerat molestie, elit elit ullamcorper ex, non fringilla massa velit imperdiet velit. Nam ornare quis velit non bibendum.

Nam a aliquam dui, vitae accumsan mauris. Nulla lacinia sollicitudin ligula, at gravida ligula porta mattis. Sed pulvinar viverra mi, ac finibus purus interdum quis. Nam interdum, justo ac malesuada laoreet, nisi lorem facilisis nulla, id vestibulum elit sem non ligula. Integer nisl nisl, tempus in aliquam sed, sagittis id magna. Maecenas eu orci vulputate, cursus turpis sed, egestas ipsum. Duis iaculis mollis risus et rutrum. Praesent a efficitur turpis. Aliquam vel blandit arcu. Nullam lacinia aliquam diam ac sodales.

Pellentesque auctor ullamcorper dignissim. Donec quis lacus tincidunt, luctus mauris sit amet, tempus tortor. In hac habitasse platea dictumst. Integer varius, orci in suscipit rhoncus, libero augue dapibus urna, quis vulputate sapien sapien eget ligula. Mauris purus neque, auctor et nibh ac, consectetur ullamcorper mauris. Proin fringilla molestie lorem, vitae eleifend neque malesuada quis. Sed facilisis iaculis sapien in bibendum. Nam vel erat ac massa dapibus mollis. Integer vehicula lectus et convallis dignissim. Cras eget fermentum orci, vel dignissim tortor. Nam at suscipit urna. Fusce iaculis diam sollicitudin, posuere lacus sit amet, tristique nunc. Cras aliquet volutpat ex, quis commodo massa interdum eget. Mauris semper nulla eu commodo lacinia. Integer ac lacinia sapien, id vehicula diam.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus eros nulla, commodo vitae lectus ut, sagittis lacinia nisl. Phasellus faucibus felis at bibendum elementum. Proin interdum, tellus in fringilla bibendum, libero ante congue mi, non placerat libero sem non justo. In hac habitasse platea dictumst. In hac habitasse platea dictumst. Morbi iaculis augue nunc, porttitor semper arcu pellentesque eget. Phasellus sem libero, elementum eget augue quis, dapibus leo.
"""
        ])
    }
}
