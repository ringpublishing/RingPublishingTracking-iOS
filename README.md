![RingPublishing](images/ringpublishing_logo.jpeg)

# AppTracking

// TODO: description

## Documentation

The documentation can be found at:

[todo link](todo link)

Integration tutorial:

[todo link](todo link)

Reference guide:

[todo link](todo link)

## Requirements

- iOS 11.0 or later
- Xcode 12 or later
- Swift 5

## Installation

### Using [CocoaPods](https://cocoapods.org)

To install it through CocoaPods simply add the following lines to your Podfile using our private Cocoapods Specs repository. Please make sure you have access to this repository granted by us.

Additions to your Podfile:
```ruby
source 'https://github.com/ringpublishing/RingPublishing-CocoaPods-Specs.git'

pod 'AppTracking'
```

### Using [Swift Package Manager](https://swift.org/package-manager/)

To isntall it into a project, add it as a dependency within your project settings using Xcode:

```swift
Package URL: "https://github.com/todo"
```

or if yo uare using manifest file, add it as a dependency there:

```swift
let Package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/todo", from: "0.1.0")
    ],
    ...
)
```

## Usage

Start by importing `AppTracking`:

```swift
import AppTracking
```

then you have access to shared module instance:

```swift
AppTracking.shared
```

For detailed example see demo project in `Example` directory or check our documentation.