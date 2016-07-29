/*

  Copyright (c) 2016 David Spooner; see License.txt

  A simple subclass of UISwitch with bindings support.

*/

import UIKit


class Toggle : UISwitch
  {

    func onStateDidChange(sender: UISwitch)
      {
        // When the value of our 'on' property changes, effect the source of our binding. 
        // If a binding exists then our property will be updated indirectly through the
        // binding machinery; otherwise it will be effected via setValue(:forKey:).

        try! setValue(sender.on, forBinding:"on")
      }


    override func didMoveToSuperview()
      {
        // While attached to our superview, ensure onStateDidChange: is invoke in response to ValueChanged events.

        if superview != nil {
          addTarget(self, action:#selector(Toggle.onStateDidChange(_:)), forControlEvents:.ValueChanged)
        }
        else {
          removeTarget(self, action:#selector(Toggle.onStateDidChange(_:)), forControlEvents:.ValueChanged)
        }

        super.didMoveToSuperview()
      }


    override func setNilValueForKey(key: String)
      {
        // Make instances resilient to setting 'on' to nil as a consequence of binding.

        if key == "on" {
          on = false
        }
        else {
          super.setNilValueForKey(key)
        }
      }

  }
