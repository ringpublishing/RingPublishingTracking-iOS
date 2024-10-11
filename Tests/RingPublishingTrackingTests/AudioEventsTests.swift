//
//  AudioEventsTests.swift
//  RingPublishingTrackingTests
//
//  Created by Bernard Bijoch on 10/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest
import Foundation

class AudioEventsFactoryTest: XCTestCase {

    var sampleAudioMetadata: AudioMetadata {
        AudioMetadata(contentId: "12167",
                      contentTitle: "Bartosz Kwolek: siatkówka nie jest całym moim życiem",
                      contentSeriesId: "67",
                      contentSeriesTitle: "W cieniu sportu",
                      mediaType: "podcast",
                      audioDuration: 3722,
                      audioStreamFormat: .mp3,
                      isContentFragment: false,
                      audioContentCategory: .free,
                      audioPlayerVersion: "1.0.0")
    }

    var sampleAudioState: AudioState {
        AudioState(currentTime: 10,
                   currentBitrate: 360,
                   visibilityState: .background,
                   audioOutput: .bluetooth)
    }

    // Test createAudioEvent with string parameters
    func testCreateAudioEventStringParameters() {
        let eventsFactory = EventsFactory()
        let event = eventsFactory.createAudioEvent(audioEvent: .start, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)

        XCTAssertFalse(event.eventParameters.isEmpty, "Audio event parameters should not be empty")
    }

    func testCreateAudioEventWhenEventIsNotStart() {
        let eventsFactory = EventsFactory()
        let event = eventsFactory.createAudioEvent(audioEvent: .paused, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)

        XCTAssertTrue(event.eventParameters["AUDIO"] == nil, "Audio parameter should not be present")
    }

    func testCreateAudioEventWhenEventIsStart() {
        let eventsFactory = EventsFactory()
        let event = eventsFactory.createAudioEvent(audioEvent: .start, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)

        XCTAssertTrue(event.eventParameters["AUDIO"] != nil, "Audio parameter should be present")
    }

    func testCreateMultipleAudioEventsWithOneContentId() {
        let eventsFactory = EventsFactory()
        let event0 = eventsFactory.createAudioEvent(audioEvent: .playing, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)
        let event1 = eventsFactory.createAudioEvent(audioEvent: .playing, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)
        let event2 = eventsFactory.createAudioEvent(audioEvent: .playing, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)
        let event3 = eventsFactory.createAudioEvent(audioEvent: .start, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)

        XCTAssertEqual(event0.eventParameters["VEN"] as? Int, 0, "Audio event parameter VER should be 0")
        XCTAssertEqual(event1.eventParameters["VEN"] as? Int, 1, "Audio event parameter VER should be 1")
        XCTAssertEqual(event2.eventParameters["VEN"] as? Int, 2, "Audio event parameter VER should be 2")
        XCTAssertEqual(event3.eventParameters["VEN"] as? Int, 0, "Audio event parameter VER should be 0")
    }

    func testCreateMultipleAudioEventsWithMultipleContentIds() {

        let sampleAudioMetadata0 = AudioMetadata(contentId: "0",
                                                 contentTitle: "Bartosz Kwolek: siatkówka nie jest całym moim życiem",
                                                 contentSeriesId: "67",
                                                 contentSeriesTitle: "W cieniu sportu",
                                                 mediaType: "podcast",
                                                 audioDuration: 3722,
                                                 audioStreamFormat: .mp3,
                                                 isContentFragment: false,
                                                 audioContentCategory: .free,
                                                 audioPlayerVersion: "1.0.0")

        let sampleAudioMetadata1 = AudioMetadata(contentId: "1",
                                                 contentTitle: "Bartosz Kwolek: siatkówka nie jest całym moim życiem",
                                                 contentSeriesId: "67",
                                                 contentSeriesTitle: "W cieniu sportu",
                                                 mediaType: "podcast",
                                                 audioDuration: 3722,
                                                 audioStreamFormat: .mp3,
                                                 isContentFragment: false,
                                                 audioContentCategory: .free,
                                                 audioPlayerVersion: "1.0.0")

        let eventsFactory = EventsFactory()
        let event00 = eventsFactory.createAudioEvent(audioEvent: .start,
                                                     audioMetadata: sampleAudioMetadata0,
                                                     audioState: sampleAudioState)
        let event01 = eventsFactory.createAudioEvent(audioEvent: .playing,
                                                     audioMetadata: sampleAudioMetadata0,
                                                     audioState: sampleAudioState)
        let event02 = eventsFactory.createAudioEvent(audioEvent: .playing,
                                                     audioMetadata: sampleAudioMetadata0,
                                                     audioState: sampleAudioState)

        let event10 = eventsFactory.createAudioEvent(audioEvent: .start,
                                                     audioMetadata: sampleAudioMetadata1,
                                                     audioState: sampleAudioState)
        let event11 = eventsFactory.createAudioEvent(audioEvent: .playing,
                                                     audioMetadata: sampleAudioMetadata1,
                                                     audioState: sampleAudioState)
        let event12 = eventsFactory.createAudioEvent(audioEvent: .start,
                                                     audioMetadata: sampleAudioMetadata1,
                                                     audioState: sampleAudioState)

        XCTAssertEqual(event00.eventParameters["VEN"] as? Int, 0)
        XCTAssertEqual(event01.eventParameters["VEN"] as? Int, 1)
        XCTAssertEqual(event02.eventParameters["VEN"] as? Int, 2)
        XCTAssertEqual(event10.eventParameters["VEN"] as? Int, 0)
        XCTAssertEqual(event11.eventParameters["VEN"] as? Int, 1)
        XCTAssertEqual(event12.eventParameters["VEN"] as? Int, 0)
    }

    func testCreateAudioEventStringParametersValues() {

        let eventsFactory = EventsFactory()
        let audioEvent = AudioEvent.start
        let event = eventsFactory.createAudioEvent(audioEvent: audioEvent, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)

        let sampleData = "audio:\(sampleAudioMetadata.contentId),\(sampleAudioMetadata.contentId)," +
                         "\(sampleAudioMetadata.audioStreamFormat.rawValue),360"
        let sampleContextJson = "{\"context\":{\"audio\":{\"output\":\"bluetooth\"},\"visible\":\"background\"}}"
        let sampleContextJsonEncoded = Data(sampleContextJson.utf8).base64EncodedString()

        XCTAssertEqual(event.eventParameters["VE"] as? String, audioEvent.rawValue)
        XCTAssertEqual(event.eventParameters["RT"] as? String, EventType.videoEvent.rawValue)
        XCTAssertEqual(event.eventParameters["PMU"] as? String, sampleAudioMetadata.contentId)
        XCTAssertEqual(event.eventParameters["VT"] as? Int, sampleAudioMetadata.audioDuration)
        XCTAssertEqual(event.eventParameters["VP"] as? Int, sampleAudioState.currentTime)
        XCTAssertEqual(event.eventParameters["VC"] as? String, sampleData)
        XCTAssertEqual(event.eventParameters["VEN"] as? Int, 0)
        XCTAssertEqual(event.eventParameters["VS"] as? String, sampleAudioMetadata.audioStreamFormat.rawValue)
        XCTAssertEqual(event.eventParameters["VSM"] as? String, "normal")
        XCTAssertEqual(event.eventParameters["XI"] as? String, sampleAudioMetadata.audioPlayerVersion)
        XCTAssertEqual(event.eventParameters["FRA"] as? Bool, sampleAudioMetadata.isContentFragment)
        XCTAssertEqual(event.eventParameters["VSLOT"] as? String, "player")
        XCTAssertEqual(event.eventParameters["VEM"] as? String, "mainAudio")
        XCTAssertEqual(event.eventParameters["VPC"] as? String, sampleAudioMetadata.audioContentCategory.rawValue)
        XCTAssertEqual(event.eventParameters["ECX"] as? String, sampleContextJsonEncoded)
    }
}
