# Changelog

All notable changes to this project will be documented in this file.
`Elevate` adheres to [Semantic Versioning](http://semver.org/).

#### 2.x Releases

* `2.0.x` Releases = [2.0.0](#200)

#### 1.x Releases

* `1.1.x` Releases = [1.1.0](#110)
* `1.0.x` Releases - [1.0.0](#100)

---

## [2.0.0](https://github.com/Nike-Inc/Elevate/releases/tag/2.0.0)

Released on 2016-09-07

#### Added

- An Elevate 2.0 Migration Guide detailing all breaking changes between 1.x and 2.0.
  - Added by [Eric Appel](https://github.com/ericappel)

#### Updated

- All source, test and example logic and project settings to compile against Swift 3.0.
  - Updated by [Eric Appel](https://github.com/ericappel)
- All protocols and implementations to use `Any` instead of `AnyObject` to match `JSONSerialization` API.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon)
- The `Parser.parseObject` API to be `Elevate.decodeObject` to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon)
- The `Parser.parseArray` API to be `Elevate.decodeArray` to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon)
- The 'Parser.parseProperties' API to be 'Parser.parseEntity' to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon)
- The `ParserPropertyMaker` and `ParserProperty` APIs to be `Schema` and `SchemaProperty` to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon)
- The 'propertyForKeyPath' API to be 'addProperty' to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon)
- The `ParserPropertyType` enum to be `SchemaPropertyProtocol` to adhere to Swift API Design Guidelines.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon)

---

## [1.1.0](https://github.com/Nike-Inc/Elevate/releases/tag/1.1.0)

Released on 2016-09-07.

#### Updated

- All source, test and example logic to compile against Swift 2.3 and Xcode 8.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).
- Dictionary key check from O(n) operation to O(1) resulting in overall parsing performance improvements of 40-50% in tests.
  - Updated by [Eric Appel](https://github.com/ericappel)
- The Travis CI yaml file to build against iOS 10 and the new suite of simulators.
  - Updated by [Christian Noon](https://github.com/cnoon).

#### Removed

- Slather reporting from the test suite due to instability issues with Xcode and Travis CI.
  - Removed by [Christian Noon](https://github.com/cnoon).
- CocoaPods linting from the Travis CI yaml file due to current instabilities with Xcode 8.
  - Removed by [Christian Noon](https://github.com/cnoon).

---

## [1.0.0](https://github.com/Nike-Inc/Elevate/releases/tag/1.0.0)

Released on 2016-06-27.

#### Added

- Initial release of Elevate.
  - Added by [Eric Appel](https://github.com/EricAppel).
