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

Elevate aims to make JSON parsing and validation simple, yet robust. This is achieved through a set of protocols and classes that can be utilized to create your own `Decodable` and `Decoder` classes. By using Surge's parsing infrastructure, you'll be able to easily parse JSON data into strongly typed model objects or simple dictionaries. In your implementation, you will specify each of the property key paths that you would like to parse and what their type is. Elevate will validate that the keys exist (if they're not optional) and validate that they are of the correct type. Validation errors will be aggregated as the JSON data is parsed. If an error is encountered, a `ParserError` will be thrown.

### Living the Dream

After you have made your model objects `Decodable` or implemented a `Decoder` for them, parsing with Elevate is as simple as:

```swift
let avatar: Avatar = try Parser.parse(data: data, forKeyPath: "response.avatar")
```

### Wha?? How?

In the previous example `Avatar` implements the `Decodable` protocol. Once you have implemented the `Decodable` protocol on an object, it can be used by Elevate to parse avatars from JSON data as a top-level object, a sub-object, or even an array of avatar objects.
  
The `Decodable` protocol specifies an initializer that must be implemented:

```swift
    init(json: AnyObject) throws
```

The `json: AnyObject` will typically be a `[String: AnyObject]` instance that was created from the `NSJSONSerialization` APIs. Use the Elevate `Parser.parseProperties` method to define the structure of the JSON data to be validated and perform the parsing.

```swift
extension Person: Decodable {
    init(json: AnyObject) throws {
        let idKeyPath = "identifier"
        let nameKeyPath = "name"
        let nicknameKeyPath = "nickname"
        let birthDateKeyPath = "birthDate"
        let isMemberKeyPath = "isMember"
        let addressesKeyPath = "addresses"

        let dateDecoder = DateDecoder(dateFormatString: "yyyy-MM-dd")

        let properties = try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath(idKeyPath, type: .Int)
            make.propertyForKeyPath(nameKeyPath, type: .String)
            make.propertyForKeyPath(nicknameKeyPath, type: .String, optional: true)
            make.propertyForKeyPath(birthDateKeyPath, type: .String, decoder: dateDecoder)
            make.propertyForKeyPath(isMemberKeyPath, type: .Bool, optional: true)
            make.propertyForKeyPath(addressesKeyPath, type: .Array, decodedToType: Address.self)
        }

        self.identifier = properties[idKeyPath] as! Int
        self.name = properties[nameKeyPath] as! String
        self.nickname = properties[nicknameKeyPath] as? String
        self.birthDate = properties[birthDateKeyPath] as! NSDate
        self.isMember = properties[isMemberKeyPath] as! Bool
        self.addresses = (properties[addressesKeyPath] as! [Any]).map { $0 as! Address) }
    }
}
```

Implementing the `Decodable` protocol in this way allows you to create fully intialized structs that can contain non-optional constants, from JSON data.
  
Some other things to notice in the example: 

1. The `Decodable` protocol conformance was implemented as an extension on the struct. This allows the struct to keep its automatic memberwise initializer.
2. Standard primative types are supported, plus NSURL, array and dictionary types. See `ParserPropertyType` definition for the full list.
3. Elevate facilitates passing a parsed property into a `Decoder` for further manipulation. See the birthDate property in the example above. The `DateDecoder` is a standard `Decoder` provided by Elevate to make date parsing hassle free.
4. A `Decoder` or `Decodable` type can be provided to a property of type `.Array` to parse each item in the array to that type. This also works with the `.Dictionary` type to parse an nested JSON object.
5. The parser guarantees that properties will be the specified type, so it is safe to use the `as!` force cast when extracting the values from the returned `[String: Any]`.
