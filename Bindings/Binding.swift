/*

  Copyright (c) 2009-2016 David Spooner; see License.txt

  A Binding synchronizes a property of a target object with a property of a source object.
  This class is used by an extension of NSObject to implement a simplified Cocoa-bindings 
  interface for iOS.

*/

import Foundation


open class Binding : NSObject
  {

    open let sourceObject: NSObject
    open let targetObject: NSObject
    open let sourceKeyPath: String
    open let targetKey: String
    open let options: [String:AnyObject]


    public init(sourceObject: NSObject, sourceKeyPath: String, targetObject: NSObject, targetKey: String, options: [String:AnyObject]?)
      {
        self.sourceObject = sourceObject
        self.sourceKeyPath = sourceKeyPath
        self.targetObject = targetObject
        self.targetKey = targetKey
        self.options = options ?? [:]

        super.init()

        sourceObject.addObserver(self, forKeyPath:sourceKeyPath, options:.initial, context:nil)
      }


    deinit
      {
        sourceObject.removeObserver(self, forKeyPath:sourceKeyPath);
      }


    open static func valueTransformerFromOptions(_ options: [String: AnyObject]?) -> ValueTransformer?
      {
        var transformer = options?[NSValueTransformerBindingOption] as? ValueTransformer
        if transformer == nil {
          if let transformerName = options?[NSValueTransformerNameBindingOption] as? String {
            transformer = ValueTransformer(forName:NSValueTransformerName(rawValue: transformerName))
            if transformer == nil {
              NSLog("unknown value transformer name: \(transformerName)")
            }
          }
        }
        return transformer
      }


    // MARK: - NSKeyValueObserving

    open override func observeValue(forKeyPath keyPath: String?, of sender: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
      {
        // Get the current source and target values.
        var sourceValue = sourceObject.value(forKeyPath: sourceKeyPath) as AnyObject?
        let targetValue = targetObject.value(forKey: targetKey) as AnyObject?

        // Substitute the placeholder if the source value is nil.
        if sourceValue == nil {
          sourceValue = options[NSNullPlaceholderBindingOption]
        }

        // Optionally transform the source value.
        if let valueTransformer = Binding.valueTransformerFromOptions(options) {
          sourceValue = valueTransformer.transformedValue(sourceValue) as AnyObject?
        }

        // Update the target if the source and target values are not equal.
        let equal: Bool
        switch (sourceValue, targetValue) {
          case (.none, .none):
            equal = true
          case (.some(let s), .some(let t)):
            equal = s === t || s.isEqual(t)
          default:
            equal = false
        }
        if !equal {
          targetObject.setValue(sourceValue, forKey:targetKey)
        }
      }

  }
