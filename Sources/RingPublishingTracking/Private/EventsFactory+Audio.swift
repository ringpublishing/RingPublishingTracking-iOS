//
//  EventsFactory+Audio.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension EventsFactory {

    func createAudioEvent(audioEvent: AudioEvent, audioMetadata: AudioMetadata, audioState: AudioState) -> Event {

        var parameters: [String: AnyHashable] = [:]
        parameters["VE"] = audioEvent.rawValue
        parameters["RT"] = EventType.videoEvent.rawValue
        parameters["PMU"] = audioMetadata.contentId.uuidValidation()
        parameters["VP"] = audioState.currentTime
        parameters["VC"] = createAudioEventVCParameter(metadata: audioMetadata, audioState: audioState)
        parameters["RR"] = audioEventSessionTimestamp(for: audioMetadata.contentId, audioEvent: audioEvent)
        parameters["VEN"] = audioEventSessionCounter(for: audioMetadata.contentId, audioEvent: audioEvent)
        parameters["VS"] = audioMetadata.audioStreamFormat.rawValue
        parameters["VSM"] = startMode
        parameters["XI"] = audioMetadata.audioPlayerVersion
        parameters["VSLOT"] = playerType
        parameters["VEM"] = mainAudio
        parameters["VPC"] = audioMetadata.audioContentCategory.rawValue
        parameters["ECX"] = createContextParam(visibility: audioState.visibilityState, output: audioState.audioOutput)
        parameters["FRA"] = audioMetadata.isContentFragment ? 1 : 0
        parameters["VT"] = audioMetadata.audioDuration

        if  [AudioEvent.start, .playingStart, .autoPlayingStart].contains(where: { $0 == audioEvent }) {
            parameters["AUDIO"] = audioMetadata.audioEventParameter.jsonString
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaStats.rawValue,
                     eventName: EventType.videoEvent.rawValue,
                     eventParameters: parameters)
    }
}

private extension EventsFactory {

    var startMode: String { "normal" }
    var playerType: String { "player" }
    var mainAudio: String { "mainAudio" }

    struct AudioContextParam: Encodable {
        let context: AudioContext
    }

    struct AudioContext: Encodable {
        let visible: String
        let audio: AudioOutputContext
    }

    struct AudioOutputContext: Encodable {
        let output: String
    }

    func createAudioEventVCParameter(metadata: AudioMetadata, audioState: AudioState) -> String {
        let contentId = metadata.mediaType == .tts ? "6" : metadata.contentId

        return "audio:\(contentId),\(contentId),\(metadata.audioStreamFormat.rawValue),\(audioState.currentBitrate)"
    }

    func audioEventSessionTimestamp(for contentId: String, audioEvent: AudioEvent) -> String {

        switch audioEvent {
        case .start:
            let timestamp = "\(Int(Date().timeIntervalSince1970 * 1000))"

            audioEventSessionTimestamps[contentId] = timestamp

            return timestamp

        default:
            return audioEventSessionTimestamps[contentId] ?? audioEventSessionTimestamp(for: contentId, audioEvent: .start)
        }
    }

    func audioEventSessionCounter(for contentId: String, audioEvent: AudioEvent) -> Int {
        switch audioEvent {
        case .start:
            audioEventSessionCounter[contentId] = 0

            return 0

        default:
            guard var counter = audioEventSessionCounter[contentId] else {
                return audioEventSessionCounter(for: contentId, audioEvent: .start)
            }

            counter += 1
            audioEventSessionCounter[contentId] = counter

            return counter
        }
    }

    private func createContextParam(visibility: AudioPlayerVisibilityState, output: AudioOutput) -> String? {
        AudioContextParam(context: AudioContext(visible: visibility.rawValue,
                                                audio: AudioOutputContext(output: output.rawValue))).jsonStringBase64
    }
}
