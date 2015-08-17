# Changelog

The changelog for Elevate includes information about the each release including any update notes, release notes as well as bug fixes, updates to existing features and new features. Additionally, Elevate follows [semantic versioning](http://semver.org/) (a.k.a semver) which makes it easy to tell whether the release was a MAJOR, MINOR or PATCH revision.

---

## 1.1.0

### Upgrade Notes

#### `Parser.parse` API Changes

The `Parser.parse` methods names have changed to remove ambiguity between the object and array versions. Their names are now `Parser.parseObject` and `Parser.parseArray`. Your project will need to be updated to change all instances of `Parser.parse` to the corresponding new method.

### Release Notes

#### Added

* Parsing data/json with an array as the root object is now supported.
* Many new tests were added. Code coverage is now over 99%.

#### Updated

* The `Parser.parse` method names have changed to remove ambiguity between the object and array versions. Their names are now `Parser.parseObject` and `Parser.parseArray`.

#### Fixed

* A public initializer was added to the `StringToIntDecoder`

## 1.0.0

This is the initial relase of Elevate. It includes:

- Validation of full JSON payload
- Parse complex JSON into strongly typed objects
- Support for optional and required values
- Convenient and flexible protocols to define object parsing
- Large object graphs can be parsed into their component objects
- Error aggregation across entire object graph
