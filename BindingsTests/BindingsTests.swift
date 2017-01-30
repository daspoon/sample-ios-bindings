/*

  Copyright (c) 2016 David Spooner; see License.txt

  Unit testing for bindings implementation.

*/

import XCTest


class BindingsTests: XCTestCase
  {

    class Subject : NSObject
      {
        dynamic var intValue: Int
        dynamic var floatValue: Float
        dynamic var stringValue: String
        dynamic var optionalStringValue: String? = nil

        init(intValue i: Int = 0, floatValue f: Float = 0, stringValue s: String = "")
          {
            intValue = i
            floatValue = f
            stringValue = s
          }
      }


    func testBasicFunction()
      {
        // Test the base bindings workflow for common numeric and object types...

        // Create source and target objects
        let source = Subject(intValue: 1, floatValue: 2.5, stringValue: "whazzup")
        let target = Subject()

        // Bind target properties to source
        target.bind("intValue", toObject:source, withKeyPath:"intValue", options:nil)
        target.bind("floatValue", toObject:source, withKeyPath:"floatValue", options:nil)
        target.bind("stringValue", toObject:source, withKeyPath:"stringValue", options:nil)

        // Ensure target properties are initialized as a result of binding.
        XCTAssert(target.intValue == 1)
        XCTAssert(target.floatValue == 2.5)
        XCTAssert(target.stringValue == "whazzup")

        // Ensure source modifications are reflected in the target.
        source.intValue = 42
        XCTAssert(target.intValue == 42)
        source.floatValue = 0.001
        XCTAssert(target.floatValue == 0.001)
        source.stringValue = "heynow"
        XCTAssert(target.stringValue == "heynow")

        // Unbind the target values.
        target.unbind("intValue")
        target.unbind("floatValue")
        target.unbind("stringValue")

        // Ensure the target is no longer affected by source changes.
        source.intValue = 43
        XCTAssert(target.intValue == 42)
        source.floatValue = 99.9
        XCTAssert(target.floatValue == 0.001)
        source.stringValue = ""
        XCTAssert(target.stringValue == "heynow")
      }


    func testTransformation()
      {
        // Test value transformers in binding options...

        let source = Subject()
        let target = Subject()

        // Bind target's intValue to that of source, using a value transformer to negate
        target.bind("intValue", toObject:source, withKeyPath:"intValue", options:[
            NSValueTransformerBindingOption: ValueTransformer.withForwardBlock({ value in
                guard let number = value as? NSNumber else { return nil }
                return NSNumber(value: -number.int32Value as Int32)
              }),
          ])

        source.intValue = 77
        XCTAssert(target.intValue == -77)
      }


    func testReverseTransformation()
      {
        // Test reversible value transformer in binding options.

        let source = Subject()
        let target = Subject()

        // Bind target's stringValue to the source's stringValue, using a value transformer to translate between upper and lower case
        target.bind("stringValue", toObject:source, withKeyPath:"stringValue", options:[
            NSValueTransformerBindingOption: ValueTransformer.withForwardBlock({
                  guard let string = $0 as? NSString else { return nil }
                  return string.uppercased as AnyObject
                },
              reverseBlock: {
                  guard let string = $0 as? NSString else { return nil }
                  return string.lowercased as AnyObject
                }),
          ])

        source.stringValue = "heynow"
        XCTAssert(target.stringValue == "HEYNOW")

        try! target.setValue("BUDDY" as AnyObject, forBinding:"stringValue")
        XCTAssert(source.stringValue == "buddy")
      }


    func testNullPlaceholder()
      {
        // Test use of null placeholder in binding options...

        let source = Subject()
        let target = Subject()

        // Bind target's stringValue to source's optionalStringValue with null placeholder option as "nil"
        target.bind("stringValue", toObject:source, withKeyPath:"optionalStringValue", options:[
            NSNullPlaceholderBindingOption: "nil" as AnyObject,
          ])
        XCTAssert(target.stringValue == "nil")

        source.optionalStringValue = "non-nil"
        XCTAssert(target.stringValue == "non-nil")
      }

  }

