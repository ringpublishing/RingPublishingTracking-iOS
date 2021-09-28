![RingPublishing](images/ringpublishing_logo.jpeg)

# RingPublishingTracking

Module for tracking events within an application.

## Documentation

The documentation can be found at:

[https://developer.ringpublishing.com/howto/tracking-mobile/index.html](https://developer.ringpublishing.com/howto/tracking-mobile/index.html)

Integration tutorial:

[https://developer.ringpublishing.com/howto/tracking-mobile/integrate-ios-sdk.html](https://developer.ringpublishing.com/howto/tracking-mobile/integrate-ios-sdk.html)

Reference guide:

[https://developer.ringpublishing.com/howto/tracking-mobile/tracking-ios-sdk.html](https://developer.ringpublishing.com/howto/tracking-mobile/tracking-ios-sdk.html)

## Requirements

- iOS 11.0 or later
- Xcode 12 or later
- Swift 5

## Installation

### Using [CocoaPods](https://cocoapods.org)

To install it through CocoaPods simply add the following lines to your Podfile using our private Cocoapods Specs repository.

Additions to your Podfile:
```ruby
source 'https://github.com/ringpublishing/RingPublishing-CocoaPods-Specs.git'

pod 'RingPublishingTracking'
```

### Using [Swift Package Manager](https://swift.org/package-manager/)

To install it into a project, add it as a dependency within your project settings using Xcode:

```swift
Package URL: "https://github.com/ringpublishing/RingPublishingTracking-iOS"
```

or if yo uare using manifest file, add it as a dependency there:

```swift
let Package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/ringpublishing/RingPublishingTracking-iOS.git", .upToNextMinor(from: "0.1.0"))
    ],
    ...
)
```

## Usage

Start by importing `RingPublishingTracking`:

```swift
import RingPublishingTracking
```

then you have access to shared module instance:

```swift
RingPublishingTracking.shared
```

For detailed example see demo project in `Example` directory or check our documentation.
