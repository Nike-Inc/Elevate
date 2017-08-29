# Elevate 2.0 Migration Guide

Elevate 2.0 is the latest major release of Elevate, a JSON parsing framework that leverages Swift to make parsing simple, reliable and composable for iOS, macOS, tvOS and watchOS.
As a major release, following Semantic Versioning conventions, 2.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Elevate 1.x to the latest APIs, as well as explain the design and structure of new and changed functionality.

## Requirements

Elevate 2.0 officially supports iOS 8.0+, macOS 10.10+, tvOS 9.0+, watchOS 2.0+, Xcode 8.0+ and Swift 3.0+.

## Reasons for Bumping to 2.0

In general, we try to avoid MAJOR version bumps unless absolutely necessary.
We realize the difficulty of transitioning between MAJOR version API changes.
Elevate 2.0 was unavoidable due to the drastic API changes introduced by Apple in Swift 3.
There was no possible way to adhere to the new Swift [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and not bump the MAJOR version.

Since we knew we had to cut a MAJOR release to support Swift 3, we decided to package up a few API changes as well while we were at it.
These changes are covered in detail in the [Breaking API Changes](#breaking-api-changes) section below.

The changes to the Elevate API were primarily naming changes and the majority of them can be made through a global Find and Replace operation.

## Benefits of Upgrading

The benefits of upgrading can be summarized as follows:

* All new APIs designed to adhere to the Swift 3 API Design Guidelines.
* All APIs were audited and updated to provide clarity for intended usage.

While these benefits are nice, the core motivation for updating to Elevate 2.0 should be because you're making the transition over to Swift 3 in your upstream targets that depend on Elevate.

---

## Breaking API Changes

Elevate 2.0 contains breaking API changes that primarily consist of renaming existing type, method and parameter names.
In addition, all protocols and APIs were updated to use `Any` rather than `AnyObject` types to match Apple's `JSONSerialization` API.

### Swift 3

#### AnyObject to Any

In Swift 3, the `NSJSONSerialization` API became `JSONSerialization` and returns `[String: Any]` dictionaries rather than `[String: AnyObject]` dictionaries.
We followed suit and updated all protocols and APIs to use `Any`.

Here's a look at the old `Decodable` and `Decoder` protocols.

```swift
public protocol Decodable {
    init(json: AnyObject) throws
}

public protocol Decoder {
    func decodeObject(object: AnyObject) throws -> Any
}
```

And here's the updated versions.

```swift
public protocol Decodable {
    init(json: Any) throws
}

public protocol Decoder {
    func decode(_ object: Any) throws -> Any
}

```

All you need to do here is update your protocol conformance to use `Any` and also remove the `Object` suffix and parameter name in the `Decoder` protocol method.

#### Parse Object and Parse Array become Decode Object and Decode Array

The `Parser.parseObject` and `Parser.parseArray` APIs are provided as convenience methods to parse a top-level key path in a JSON document without having to build a schema for it.
These methods do not actually perform the work of parsing, they simply create a lightweight schema for you and call the actual parsing APIs on your behalf.
To clarify the intent and usage of these APIs they have been updated to `Elevate.decodeObject` and `Elevate.decodeArray` respectively.
The parameter names have also been updated to follow Swift 3 API Design Guideline naming conventions.

Here are the previous APIs in use:
```swift
let result: String = try Parser.parseObject(data: data, forKeyPath: "key")
let testObjects: [TestObject] = try Parser.parseArray(data: data, forKeyPath: "items")
```

And here are the updated versions.

```swift
let result: String = try Elevate.decodeObject(from: data, atKeyPath: "key")
let testObjects: [TestObject] = try Elevate.decodeArray(from: data, atKeyPath: "items")
```

Many of these changes can be made with a global find and replace operation.

#### Creating a Schema and Parsing It

Elevate has always followed a maker pattern to build up the list of properties that you expect to be parsed for a given JSON document.
The previous API was concise and read well, but did not clearly communicate what the developer was actually doing while following the pattern.
The updated APIs more clearly represent the activity of building a schema in the body of the closure and parsing it.

Here is an example of the previous set of APIs.
```swift
let properties = try Parser.parseProperties(json: json) { make in
	make.propertyForKeyPath(idKeyPath, type: .Int)
	make.propertyForKeyPath(nameKeyPath, type: .String)
	make.propertyForKeyPath(nicknameKeyPath, type: .String, optional: true)
	make.propertyForKeyPath(birthDateKeyPath, type: .String, decoder: dateDecoder)
	make.propertyForKeyPath(isMemberKeyPath, type: .Bool, optional: true)
	make.propertyForKeyPath(addressesKeyPath, type: .Array, decodedToType: Address.self)
}
```

And here is the updated version.
```swift
let entity = try Parser.parseEntity(json: json) { schema in
	schema.addProperty(keyPath: idKeyPath, type: .Int)
	schema.addProperty(keyPath: nameKeyPath, type: .String)
	schema.addProperty(keyPath: nicknameKeyPath, type: .String, optional: true)
	schema.addProperty(keyPath: birthDateKeyPath, type: .String, decoder: dateDecoder)
	schema.addProperty(keyPath: isMemberKeyPath, type: .Bool, optional: true)
	schema.addProperty(keyPath: addressesKeyPath, type: .Array, decodedToType: Address.self)
}
```

The `Parser.parseProperties` API has been updated to `Parser.parseEntity` to more clearly reflect the work that it is doing to parse the entity defined by your schema from the JSON document. 

We highly recommend that you update the closure parameter name from `make` to `schema` throughout your code base.
Schema more accurately communicates what is being built in the closure.
The `propertyForKeyPath` API has also been updated to `addProperty` to reflect that each property is being added to the schema being built.

#### Other Changes

To more accurately reflect their purpose the `ParserPropertyMaker` and `ParserProperty` APIs were updated to `Schema` and `SchemaProperty` respectively.
You typically won't have references to these types directly in your source code.
In addition, the enum used to indicate the type of each JSON property was updated from `JSONPropertyType` to `SchemaPropertyProtocol`.
