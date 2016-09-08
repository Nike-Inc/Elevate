# Changelog

All notable changes to this project will be documented in this file.
`Elevate` adheres to [Semantic Versioning](http://semver.org/).

#### 1.x Releases

* `1.1.x` Releases = [1.1.0](#110)
* `1.0.x` Releases - [1.0.0](#100)

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
