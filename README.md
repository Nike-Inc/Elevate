# Elevate

[![Build Status](https://travis-ci.org/Nike-Inc/Elevate.svg?branch=master)](https://travis-ci.org/Nike-Inc/Elevate)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Elevate.svg)](https://img.shields.io/cocoapods/v/Elevate.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Elevate.svg?style=flat)](http://cocoadocs.org/docsets/Elevate)

Elevate is a JSON parsing framework that leverages Swift to make parsing simple, reliable and composable.

## Features

- [X] Validation of full JSON payload
- [X] Parse complex JSON into strongly typed objects
- [X] Support for optional and required values
- [X] Convenient and flexible protocols to define object parsing
- [X] Large object graphs can be parsed into their component objects
- [X] Error aggregation across entire object graph

## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.2+
- Swift 3.0+

## Communication

- Need help? Open an issue.
- Have a feature request? Open an issue.
- Find a bug? Open an issue.
- Want to contribute? Fork the repo and submit a pull request.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
[sudo] gem install cocoapods
```

> CocoaPods 1.0+ is required.

To integrate Elevate into your Xcode project using CocoaPods, specify it in your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

pod 'Elevate', '~> 2.2'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```bash
brew update
brew install carthage
```

To integrate Elevate into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```bash
github "Nike-Inc/Elevate" ~> 2.2
```

To build Elevate on iOS only, use the following Carthage command:

```bash
carthage update --platform iOS
```

---

## Usage

Elevate aims to make JSON parsing and validation simple, yet robust. This is achieved through a set of protocols and classes that can be utilized to create `Decodable` and `Decoder` classes. By using Elevate's parsing infrastructure, you'll be able to easily parse JSON data into strongly typed model objects or simple dictionaries by specifying each property key path and its associated type. Elevate will validate that the keys exist (if they're not optional) and that they are of the correct type. Validation errors will be aggregated as the JSON data is parsed. If an error is encountered, a `ParserError` will be thrown.

Elevate also supports encoding model objects back into JSON objects through the light-weight `Encodable` protocol. Convenience extensions have been added to collection types to make it easy to encode nested objects in a single pass.

### Parsing JSON with Elevate

After you have made your model objects `Decodable` or implemented a `Decoder` for them, parsing with Elevate is as simple as:

```swift
let avatar: Avatar = try Elevate.decodeObject(from: data, atKeyPath: "response.avatar")
```

> Pass an empty string into `atKeyPath` if your object or array is at the root level. 

### Creating Decodables

In the previous example `Avatar` implements the `Decodable` protocol. By implementing the `Decodable` protocol on an object, it can be used by Elevate to parse avatars from JSON data as a top-level object, a sub-object, or even an array of avatar objects.

```swift
public protocol Decodable {
    init(json: Any) throws
}
```

The `json: Any` will typically be a `[String: Any]` instance that was created from the `JSONSerialization` APIs. Use the Elevate `Parser.parseEntity` method to define the structure of the JSON data to be validated and perform the parsing.

```swift
struct Person {
    let identifier: String
    let name: String
    let nickname: String?
    let birthDate: Date
    let isMember: Bool?
    let addresses: [Address]
}

extension Person: Decodable {
    fileprivate struct KeyPath {
        static let id = "identifier"
        static let name = "name"
        static let nickname = "nickname"
        static let birthDate = "birthDate"
        static let isMember = "isMember"
        static let addresses = "addresses"
    }

    init(json: Any) throws {
        let dateDecoder = DateDecoder(dateFormatString: "yyyy-MM-dd")

        let entity = try Parser.parseEntity(json: json) { schema in
            schema.addProperty(keyPath: KeyPath.id, type: .int)
            schema.addProperty(keyPath: KeyPath.name, type: .string)
            schema.addProperty(keyPath: KeyPath.nickname, type: .string, optional: true)
            schema.addProperty(keyPath: KeyPath.birthDate, type: .string, decoder: dateDecoder)
            schema.addProperty(keyPath: KeyPath.isMember, type: .bool, optional: true)
            schema.addProperty(keyPath: KeyPath.addresses, type: .array, decodableType: Address.self)
        }

        self.identifier = entity <-! KeyPath.id
        self.name = entity <-! KeyPath.name
        self.nickname = entity <-? KeyPath.nickname
        self.birthDate = entity <-! KeyPath.birthDate
        self.isMember = entity <-? KeyPath.isMember
        self.addresses = entity <--! KeyPath.addresses
    }
}
```

Implementing the `Decodable` protocol in this way allows you to create fully intialized structs that can contain non-optional constants from JSON data.

Some other things worth noting in this example:

1. The `Decodable` protocol conformance was implemented as an extension on the struct. This allows the struct to keep its automatic memberwise initializer.
2. Standard primitive types are supported as well as `URL`, `Array`, and `Dictionary` types. See `ParserPropertyProtocol` definition for the full list.
3. Elevate facilitates passing a parsed property into a `Decoder` for further manipulation. See the `birthDate` property in the example above. The `DateDecoder` is a standard `Decoder` provided by Elevate to make date parsing hassle free.
4. A `Decoder` or `Decodable` type can be provided to a property of type `.Array` to parse each item in the array to that type. This also works with the `.Dictionary` type to parse a nested JSON object.
5. The parser guarantees that properties will be of the specified type, so it is safe to use the custom operators to automatically extract the `Any` value from the `entity` dictionary and cast it to the return type.

### Property Extraction Operators

Elevate contains four property extraction operators to make it easy to extract values out of the `entity` dictionary and cast the `Any` value to the appropriate type.

* `<-!` - Extracts the value from the `entity` dictionary for the specified key. This operator should only be used on non-optional properties.
* `<-?` - Extracts the optional value from the `entity` dictionary for the specified key. This operator should only be used on optional properties.
* `<--!` - Extracts the array from the `entity` dictionary for the specified key as the specified array type. This operator should only be used on non-optional array properties.
* `<--?` - Extracts the array from the `entity` dictionary for the specified key as the specified optional array type.

### Creating Encodables

Extending a model object to conform to the `Encodable` protocol is less involved than making it `Decodable`. Since your object is already strongly typed, it only needs to be converted into a JSON friendly `Any` object. Building on the previous `Person` type, let's make it conform to the `Encodable` protocol.

```swift
extension Person: Encodable {
    var json: Any {
        var json: [String: Any] = [
            KeyPath.id: identifier,
            KeyPath.name: name,
            KeyPath.birthDate: birthDate,
            KeyPath.addresses: addresses.json
        ]

        if let nickname = nickname { json[KeyPath.nickname] = nickname }
        if let isMember = isMember { json[KeyPath.isMember] = isMember }

        return json
    }
}
```

As you can see in the example, converting the `Person` into a JSON dictionary is straightforward. It's also easy to convert the array of `Address` objects into JSON by calling the `json` property on the array. This works because `Address` also conforms to `Encodable`. The collection type extensions on `Array`, `Set` and `Dictionary` make it easy to convert a complex objects with multiple layers of `Encodable` objects into a JSON objects.

---
  
## Advanced Usage

### Decoders

In most cases implementing a `Decodable` model object is all that is needed to parse JSON using Elevate. There are some instances though where you will need more flexibility in the way that the JSON is parsed. This is where the `Decoder` protocol comes in.

```swift
public protocol Decoder {
    func decode(_ object: Any) throws -> Any
}
```

A `Decoder` is generally implemented as a separate object that returns instances of the desired model object. This is useful when you have multiple JSON mappings for a single model object, or if you are aggregating data across multiple JSON payloads. For example, if there are two separate services that return JSON for `Avatar` objects that have a slightly different property structure, a `Decoder` could be created for each mapping to handle them individually.

> The input type and output types are intentionally vague to allow for flexibility. A `Decoder` can return any type you want -- a strongly typed model object, a dictionary, etc. It can even dynamically return different types at runtime if needed.

#### Using Multiple Decoders

```swift
class AvatarDecoder: Decoder {
    func decode(_ object: Any) throws -> Any {
        let urlKeyPath = "url"
        let widthKeyPath = "width"
        let heightKeyPath = "height"

        let entity = try Parser.parseEntity(json: object) { schema in
            schema.addProperty(keyPath: urlKeyPath, type: .url)
            schema.addProperty(keyPath: widthKeyPath, type: .int)
            schema.addProperty(keyPath: heightKeyPath, type: .int)
        }

        return Avatar(
            URL: entity <-! urlKeyPath,
            width: entity <-! widthKeyPath,
            height: entity <-! heightKeyPath
        )
    }
}
```

```swift
class AlternateAvatarDecoder: Decoder {
    func decode(_ object: Any) throws -> Any {
        let locationKeyPath = "location"
        let wKeyPath = "w"
        let hKeyPath = "h"

        let entity = try Parser.parseEntity(json: object) { schema in
            schema.addProperty(keyPath: locationKeyPath, type: .url)
            schema.addProperty(keyPath: wKeyPath, type: .int)
            schema.addProperty(keyPath: hKeyPath, type: .int)
        }

        return Avatar(
            URL: entity <-! locationKeyPath,
            width: entity <-! wKeyPath,
            height: entity <-! hKeyPath
        )
    }
}
```

Then to use the two different `Decoder` objects with the `Parser`:

```swift
let avatar1: Avatar = try Elevate.decodeObject(
    from: data1, 
    atKeyPath: "response.avatar", 
    with: AvatarDecoder()
)

let avatar2: Avatar = try Elevate.decodeObject(
    from: data2, 
    atKeyPath: "alternative.response.avatar", 
    with: AlternateAvatarDecoder()
)
```

Each `Decoder` is designed to handle a different JSON structure for creating an `Avatar`. Each uses the key paths specific to the JSON data it's dealing with, then maps those back to the properties on the `Avatar` object. This is a very simple example to demonstration purposes. There are MANY more complex examples that could be handled in a similar manner via the `Decoder` protocol.

### Decoders as Property Value Transformers

A second use for the `Decoder` protocol is to allow for the value of a property to be further manipulated. The most common example is a date string. Here is how the `DateDecoder` implements the `Decoder` protocol:
  
```swift
public func decode(_ object: Any) throws -> Any {
    if let string = object as? String {
        return try dateFromString(string, withFormatter:self.dateFormatter)
    } else {
        let description = "DateParser object to parse was not a String."
        throw ParserError.Validation(failureReason: description)
    }
}
```
  
And here is how it's used to parse a JSON date string:
  
```swift
let dateDecoder = DateDecoder(dateFormatString: "yyyy-MM-dd 'at' HH:mm")

let entity = try Parser.parseEntity(data: data) { schema in
    schema.addProperty(keyPath: "dateString", type: .string, decoder: dateDecoder)
}
```

You are free to create any decoders that you like and use them with your properties during parsing. Some other uses would be to create a `StringToBoolDecoder` or `StringToFloatDecoder` that parses a `Bool` or `Float` from a JSON string value. The `DateDecoder` and `StringToIntDecoder` are already included in Elevate for your convenience.
  
---
  
## Creators

* [Eric Appel](https://github.com/EricAppel) - [@EricAppel](http://twitter.com/EricAppel)
* [Christian Noon](https://github.com/cnoon) - [@Christian_Noon](http://twitter.com/Christian_Noon)
