# Elevate

Elevate brings sanity and reliability to JSON parsing in Swift.

## Features

- Full validation of JSON payload
- Support for optional and required values
- Parse complex JSON into strongly typed objects
- Convenient and flexible protocols to define object parsing
- Large object graphs can be parsed into their component objects
- Error aggregation across entire object graph

## Requirements

- iOS 8.0+ / Mac OS X 10.10+
- Xcode 7.0+

## Dependencies

* None!

## Communication

- Need help? Open a [Question](https://jira.nike.com/browse/bmd). (Component => `Elevate`)
- Have a feature request? Open a [Feature Request](https://jira.nike.com/browse/bmd). (Component => `Elevate`)
- Find a bug? Open a [Bug](https://jira.nike.com/browse/bmd). (Component => `Elevate`)
- Want to contribute? Fork the repo and submit a pull request.

> These tickets go directly to the developers of Elevate who are very adament about providing top notch support for this library. Please don't hesitate to open tickets for any type of issue. If we don't know about it, we can't fix it, support it or build it.

---

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
[sudo] gem install cocoapods
```

To integrate Surge into your Xcode project using CocoaPods, specify it in your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
platform :ios, '8.0'
use_frameworks!

# Spec sources
source 'ssh://git@stash.nikedev.com/ncps/nike-private-spec.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'Elevate', '~> 1.0.0'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with Homebrew using the following command:

```bash
brew update
brew install carthage
```

To integrate Elevate into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```bash
git "ssh://git@stash.nikedev.com/srg/elevate.git" ~> 1.0.0
```

To build Elevate on iOS only, use the following Carthage command:

```bash
carthage update --platform iOS
```

---

## Usage
