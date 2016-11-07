/*

  Copyright (c) 2009-2016 David Spooner; see License.txt

  An extension of NSObject implementing a simplified Cocoa bindings interface for iOS.

*/

import Foundation


#if os(iOS)
// Subset of Cocoa-bindings option keys supported by bind(:toObject:withKeyPath:options:):
public let NSNullPlaceholderBindingOption = "NSNullPlaceholderBindingOption"
public let NSValueTransformerBindingOption = "NSValueTransformerBindingOption"
public let NSValueTransformerNameBindingOption = "NSValueTransformerNameBindingOption"

// Cocoa-bindings constants relevant to this implementation:
let NSObservedObjectKey = "NSObservedObject"
let NSObservedKeyPathKey = "NSObservedKeyPath"
let NSOptionsKey = "NSOptions"
#endif


private var bindingsKey = 0
    // Variable address used as key for the associated objects API.


public extension NSObject
  {

    #if os(iOS)
    // The following methods mimic the Cocoa-bindings interface on macOS:

    public func bind(key: String, toObject sourceObject: NSObject, withKeyPath keyPath: String, options: [String:AnyObject]?)
      {
        var bindings: NSMutableDictionary! = objc_getAssociatedObject(self, &bindingsKey) as? NSMutableDictionary
        if bindings == nil {
          bindings = NSMutableDictionary()
          objc_setAssociatedObject(self, &bindingsKey, bindings, .OBJC_ASSOCIATION_RETAIN)
        }

        bindings[key] = Binding(sourceObject: sourceObject, sourceKeyPath: keyPath, targetObject: self, targetKey: key, options: options)
      }


    public func unbind(key: String)
      {
        let bindings = objc_getAssociatedObject(self, &bindingsKey) as! NSMutableDictionary
        bindings[key] = nil
      }


    public func infoForBinding(key: String) -> [String: AnyObject]?
      {
        if let binding = (objc_getAssociatedObject(self, &bindingsKey) as? NSMutableDictionary)?[key] as? Binding {
          return [
              NSObservedObjectKey: binding.sourceObject,
              NSObservedKeyPathKey: binding.sourceKeyPath,
              NSOptionsKey: binding.options ?? [:],
            ]
        }
        return nil
      }

    #endif


    public func setValue(value: AnyObject?, forBinding key: String) throws
      {
        // If a binding exists for the specified property then the coresponding property of that binding's source object
        // is set; otherwise we defer to -setValue:forKey:. An exception is raised if the source object for the binding
        // fails to validate the given value. This method is useful when implementing bindings-aware UI elements.

        if let info = infoForBinding(key) {
          // Extract the source object and keypath for the binding
          let object = info[NSObservedObjectKey] as! NSObject
          let keypath = info[NSObservedKeyPathKey] as! String
          let options = info[NSOptionsKey] as? [String: AnyObject]
          // Start with the given value
          var validValue = value
          // Apply the reverse transformation specified in the binding options, if applicable.
          if let transformer = Binding.valueTransformerFromOptions(options) {
            if transformer.dynamicType.allowsReverseTransformation() {
              validValue = transformer.reverseTransformedValue(validValue)
            }
          }
          // Ask the observed object to validate the given value, throwing on failure
          try object.validateValue(&validValue, forKeyPath:keypath)
          object.setValue(validValue, forKeyPath:keypath)
        }
        else {
          // No binding, so effect the receiver's property directly.
          setValue(value, forKey:key)
        }
      }

  }
