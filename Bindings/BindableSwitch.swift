/*

  Copyright (c) 2016 David Spooner; see License.txt

  A simple subclass of UISwitch with bindings support.

*/

import UIKit


public class BindableSwitch : UISwitch
  {

    func onStateDidChange(_ sender: UISwitch)
      {
        // When the value of our 'on' property changes, effect the source of our binding. 
        // If a binding exists then our property will be updated indirectly through the
        // binding machinery; otherwise it will be effected via setValue(:forKey:).

        try! setValue(NSNumber(value:sender.isOn), forBinding:"on")
      }


    override public func didMoveToSuperview()
      {
        // While attached to our superview, ensure onStateDidChange: is invoke in response to ValueChanged events.

        if superview != nil {
          addTarget(self, action:#selector(BindableSwitch.onStateDidChange(_:)), for:.valueChanged)
        }
        else {
          removeTarget(self, action:#selector(BindableSwitch.onStateDidChange(_:)), for:.valueChanged)
        }

        super.didMoveToSuperview()
      }


    override public func setNilValueForKey(_ key: String)
      {
        // Make instances resilient to setting 'on' to nil as a consequence of binding.

        if key == "on" {
          isOn = false
        }
        else {
          super.setNilValueForKey(key)
        }
      }

  }
