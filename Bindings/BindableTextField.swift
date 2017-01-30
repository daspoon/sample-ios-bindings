/*

  Copyright (c) 2017 David Spooner; see License.txt

  A simple subclass of UITextField with bindings support.

*/

import UIKit


public class BindableTextField : UITextField
  {

    func textDidChange(_ sender: AnyObject)
      {
        // When our 'text' property changes, effect the source of our binding.

        try! setValue((text ?? "") as AnyObject, forBinding:"text")
      }


    override public func didMoveToSuperview()
      {
        // While attached to our superview, register the textDidChange: action in response to ValueChanged events.

        if superview != nil {
          NotificationCenter.default.addObserver(self, selector:#selector(textDidChange(_:)), name:.UITextFieldTextDidChange, object:self)
        }
        else {
          NotificationCenter.default.removeObserver(self, name:.UITextFieldTextDidChange, object:self)
        }

        super.didMoveToSuperview()
      }


    override public func setNilValueForKey(_ key: String)
      {
        // Make instances resilient to setting 'text' to nil as a consequence of binding.

        if key == "text" {
          text = ""
        }
        else {
          super.setNilValueForKey(key)
        }
      }

  }
