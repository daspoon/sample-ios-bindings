/*

  Copyright (c) 2016 David Spooner; see License.txt

  A simple view controller demonstrating use of Cocoa bindings for iOS.

*/

import UIKit


class ViewController: UIViewController
  {

    @IBOutlet var nameVisibleSwitch: UISwitch!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameField: UITextField!


    override func viewWillAppear(animated: Bool)
      {
        super.viewWillAppear(animated)

        // Bind visibility of the name label/field to the 'on' state of the switch.
        for component in [nameLabel, nameField] {
          component.bind("hidden", toObject:nameVisibleSwitch, withKeyPath:"on", options:[
              NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName,
            ])
        }
      }


    override func viewDidDisappear(animated: Bool)
      {
        super.viewDidDisappear(animated)

        // Unbind the visibility of the name label/field
        for component in [nameLabel, nameField] {
          component.unbind("hidden")
        }
      }

  }
