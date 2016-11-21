# Changelog

All notable changes to this project will be documented in this file.
`Elevate` adheres to [Semantic Versioning](http://semver.org/).

#### 2.x Releases

* `2.1.x` Releases = [2.1.0](#210)
* `2.0.x` Releases = [2.0.0](#200)

#### 1.x Releases

* `1.1.x` Releases = [1.1.0](#110)
* `1.0.x` Releases - [1.0.0](#100)

---

## [2.1.0](https://github.com/Nike-Inc/Elevate/releases/tag/2.1.0)

Released on 2016-11-21.

#### Added

- The `.swift-version` file pointing at Swift 3.0 to support CocoaPods.
  - Added by [Christian Noon](https://github.com/cnoon).
- The `Encodable` protocol along with extensions for common types and unit tests.
  - Added by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Elevate/pull/21).
- The `Encodable` section to the README and updated `Decodable` to use `KeyPath` struct.
  - Added by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Elevate/pull/21).

#### Updated

- The `Person` example to use an extension in the README.
  - Updated by [Rich Ellis](https://github.com/richellis) in Pull Request
  [#16](https://github.com/Nike-Inc/Elevate/pull/16).
- Xcode project settings to latest defaults and disabled code signing.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Elevate/pull/21).
- Xcode project by disabling code signing on all targets and removed duplicate code signing identities.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Elevate/pull/21).

#### Fixed

- Incorrect enum case in README for type arguments.
  - Fixed by [Dave Camp](https://github.com/AtomicCat) in Pull Request
  [#19](https://github.com/Nike-Inc/Elevate/pull/19).
- Issue where incorrect parameter name was used in multiple decoders section of the README.
  - Fixed by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#20](https://github.com/Nike-Inc/Elevate/pull/20).

---

## [2.0.0](https://github.com/Nike-Inc/Elevate/releases/tag/2.0.0)

Released on 2016-09-08.

#### Added

- An Elevate 2.0 Migration Guide detailing all breaking changes between 1.x and 2.0.
  - Added by [Eric Appel](https://github.com/ericappel)

#### Updated

- All source, test and example logic and project settings to compile against Swift 3.0.
  - Updated by [Eric Appel](https://github.com/ericappel).
- All protocols and implementations to use `Any` instead of `AnyObject` to match `JSONSerialization` API.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).
- The `Parser.parseObject` API to be `Elevate.decodeObject` to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).
- The `Parser.parseArray` API to be `Elevate.decodeArray` to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).
- The 'Parser.parseProperties' API to be 'Parser.parseEntity' to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).
- The `ParserPropertyMaker` and `ParserProperty` APIs to be `Schema` and `SchemaProperty` to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).
- The 'propertyForKeyPath' API to be 'addProperty' to add clarity for intended usage.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).
- The `ParserPropertyType` enum to be `SchemaPropertyProtocol` to adhere to Swift API Design Guidelines.
  - Updated by [Eric Appel](https://github.com/ericappel) and [Christian Noon](https://github.com/cnoon).

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
