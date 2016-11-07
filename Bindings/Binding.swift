/*

  Copyright (c) 2009-2016 David Spooner; see License.txt

  A Binding synchronizes a property of a target object with a property of a source object.
  This class is used by an extension of NSObject to implement a simplified Cocoa-bindings 
  interface for iOS.

*/

import Foundation


public class Binding : NSObject
  {

    public let sourceObject: NSObject
    public let targetObject: NSObject
    public let sourceKeyPath: String
    public let targetKey: String
    public let options: [String:AnyObject]?


    public init(sourceObject: NSObject, sourceKeyPath: String, targetObject: NSObject, targetKey: String, options: [String:AnyObject]?)
      {
        self.sourceObject = sourceObject
        self.sourceKeyPath = sourceKeyPath
        self.targetObject = targetObject
        self.targetKey = targetKey
        self.options = options;

        super.init()

        sourceObject.addObserver(self, forKeyPath:sourceKeyPath, options:.Initial, context:nil)
      }


    deinit
      {
        sourceObject.removeObserver(self, forKeyPath:sourceKeyPath);
      }


    public static func valueTransformerFromOptions(options: [String: AnyObject]?) -> NSValueTransformer?
      {
        var transformer = options?[NSValueTransformerBindingOption] as? NSValueTransformer
        if transformer == nil {
          if let transformerName = options?[NSValueTransformerNameBindingOption] as? String {
            transformer = NSValueTransformer(forName:transformerName)
            if transformer == nil {
              NSLog("unknown value transformer name: \(transformerName)")
            }
          }
        }
        return transformer
      }


    // MARK: - NSKeyValueObserving

    public override func observeValueForKeyPath(keyPath: String?, ofObject sender: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
      {
        // Get the current source and target values.
        var sourceValue = sourceObject.valueForKeyPath(sourceKeyPath)
        let targetValue = targetObject.valueForKey(targetKey)

        // Substitute the placeholder if the source value is nil.
        if sourceValue == nil {
          sourceValue = options?[NSNullPlaceholderBindingOption]
        }

        // Optionally transform the source value.
        if let valueTransformer = Binding.valueTransformerFromOptions(options) {
          sourceValue = valueTransformer.transformedValue(sourceValue)
        }

        // Update the target if the source and target values are not equal.
        let equal: Bool
        switch (sourceValue, targetValue) {
          case (.None, .None):
            equal = true
          case (.Some(let s), .Some(let t)):
            equal = s === t || s.isEqual(t)
          default:
            equal = false
        }
        if !equal {
          targetObject.setValue(sourceValue, forKey:targetKey)
        }
      }

  }
