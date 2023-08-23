//
//  EventsFactory.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 08/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class EventsFactory {

    private var videoEventSessionTimestamps = [String: String]() // PMU: RR
    private var videoEventSessionCounter = [String: Int]() // PMU: VEN

    // MARK: Click

    func createClickEvent(selectedElementName: String?,
                          publicationUrl: URL?,
                          contentIdentifier: String?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        if let selectedElementName = selectedElementName {
            parameters["VE"] = selectedElementName
        }

        if let publicationUrl = publicationUrl {
            parameters["VU"] = publicationUrl.absoluteString
        }

        if let contentIdentifier = contentIdentifier {
            parameters["PU"] = contentIdentifier
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaEvents.rawValue,
                     eventName: EventType.click.rawValue,
                     eventParameters: parameters)
    }

    // MARK: User action

    func createUserActionEvent(actionName: String, actionSubtypeName: String, parameter: UserActionParameter) -> Event {
        var parameters: [String: AnyHashable] = [
            "VE": actionName,
            "VC": actionSubtypeName
        ]

        let payload: String?

        switch parameter {
        case .parameters(let dictionary):
            if let data = try? dictionary.dataUsingJSONSerialization(),
               let string = String(data: data, encoding: .utf8) {
                payload = string
            } else {
                payload = nil
                Logger.log("Could not parse given parameters to JSON")
            }
        case .plain(let string):
            payload = string
        }

        if let payload = payload {
            parameters["VM"] = payload
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaEvents.rawValue,
                     eventName: EventType.userAction.rawValue,
                     eventParameters: parameters)
    }

    // MARK: Page View

    func createPageViewEvent(contentIdentifier: String?, contentMetadata: ContentMetadata?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        if let contentIdentifier = contentIdentifier {
            parameters["PU"] = contentIdentifier
        }

        if let contentMetadata = contentMetadata {
            parameters["DX"] = contentMetadata.dxParameter
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaStats.rawValue,
                     eventName: EventType.pageView.rawValue,
                     eventParameters: parameters)
    }

    // MARK: Keep Alive

    func createKeepAliveEvent(metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) -> Event {
        var parameters: [String: AnyHashable] = [:]

        let measurements = metaData.keepAliveContentStatus

        parameters["DX"] = contentMetadata.dxParameter
        parameters["PU"] = contentMetadata.contentId.trimmingCharacters(in: .whitespacesAndNewlines)
        parameters["KDS"] = measurements.map { "\(Int($0.contentSize.width))x\(Int($0.contentSize.height))" }
        parameters["KHF"] = metaData.hasFocus
        parameters["KMT"] = metaData.keepAliveMeasureType.map { $0.rawValue }
        parameters["KTA"] = 1
        parameters["KTP"] = metaData.timings
        parameters["KTS"] = measurements.map { Int($0.scrollOffset) }

        return Event(analyticsSystemName: AnalyticsSystem.timescore.rawValue,
                     eventName: EventType.keepAlive.rawValue,
                     eventParameters: parameters)
    }

    // MARK: Video event

    func createVideoEvent(for videoEvent: VideoEvent, videoMetadata: VideoMetadata, videoState: VideoState) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["VE"] = videoEvent.veParameter
        parameters["RT"] = EventType.videoEvent.rawValue
        parameters["PMU"] = videoMetadata.contentId
        parameters["MUTED"] = videoState.isMuted ? 1 : 0
        parameters["VT"] = videoMetadata.videoDuration
        parameters["VP"] = videoState.currentTime
        parameters["VC"] = createVideoEventVCParameter(videoMetadata: videoMetadata, videoState: videoState)
        parameters["RR"] = videoEventSessionTimestamp(for: videoMetadata.contentId, videoEvent: videoEvent)
        parameters["VEN"] = videoEventSessionCounter(for: videoMetadata.contentId, videoEvent: videoEvent)
        parameters["VS"] = videoMetadata.videoStreamFormat.parameterFormatName
        parameters["VSM"] = videoState.startMode.parameterName
        parameters["XI"] = videoMetadata.videoPlayerVersion
        parameters["VSLOT"] = videoMetadata.isMainContentPiece ? "player" : "splayer"
        parameters["VEM"] = videoMetadata.isMainContentPiece ? "mainVideo" : "inTextVideo"
        parameters["VNA"] = videoMetadata.videoAdsConfiguration.noAdsParameterName
        parameters["VPC"] = videoMetadata.videoContentCategory.parameterName

        return Event(analyticsSystemName: AnalyticsSystem.kropkaStats.rawValue,
                     eventName: EventType.videoEvent.rawValue,
                     eventParameters: parameters)
    }

    // MARK: Error

    func createErrorEvent(for event: Event, applicationRootPath: String?) -> Event {
        let applicationName = [applicationRootPath, Constants.applicationPrefix].compactMap { $0 }.joined(separator: ".")
        let eventInfo = "(name: \(event.eventName), size: \(event.sizeInBytes), reason: exceeding size limit)"

        let message = "Application \(applicationName) tried to send event \(eventInfo)."

        return Event(analyticsSystemName: AnalyticsSystem.kropkaMonitoring.rawValue,
                     eventName: EventType.error.rawValue,
                     eventParameters: [
                        "VE": "AppError",
                        "VM": message
                     ])
    }
}

// MARK: Private
private extension EventsFactory {

    func createVideoEventVCParameter(videoMetadata: VideoMetadata, videoState: VideoState) -> String {
        // Parameters format:
        // [prefix]:[ckmId],[publicationId],video/[type],[bitrate]
        // Example: "video:2334518,2334518.275928614,video/hls,4000"

        let prefix = Constants.videoEventParametersPrefix
        let ckmId = videoMetadata.publicationId.split(separator: ".").map { String($0) }[0]
        let publicationId = videoMetadata.publicationId
        let videoFormat = "video/\(videoMetadata.videoStreamFormat.parameterFormatName)"

        // Send bitrate as Int
        let bitrate: String
        if let bitrateAsDouble = Double(videoState.currentBitrate) {
            bitrate = "\(Int(floor(bitrateAsDouble)))"
        } else {
            bitrate = videoState.currentBitrate
        }

        return "\(prefix):\(ckmId),\(publicationId),\(videoFormat),\(bitrate)"
    }

    func videoEventSessionTimestamp(for contentId: String, videoEvent: VideoEvent) -> String {
        // For each new video session (recognized by .start event) generate new timestamp
        // Timestamp format: 1692697330517 - current timestamp with miliseconds with 3 digits precision

        switch videoEvent {
        case .start:
            let timestamp = "\(Int(Date().timeIntervalSince1970 * 1000))"

            videoEventSessionTimestamps[contentId] = timestamp

            return timestamp

        default:
            // If timestamp does not exists, force generation
            return videoEventSessionTimestamps[contentId] ?? videoEventSessionTimestamp(for: contentId, videoEvent: .start)
        }
    }

    func videoEventSessionCounter(for contentId: String, videoEvent: VideoEvent) -> Int {
        // For each new video session (recognized by .start event) reset events counter

        switch videoEvent {
        case .start:
            videoEventSessionCounter[contentId] = 0

            return 0

        default:
            // If counter does not exists, force generation
            guard var counter = videoEventSessionCounter[contentId] else {
                return videoEventSessionCounter(for: contentId, videoEvent: .start)
            }

            counter += 1
            videoEventSessionCounter[contentId] = counter

            return counter
        }
    }
}
