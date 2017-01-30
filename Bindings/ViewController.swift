/*

  Copyright (c) 2016 David Spooner; see License.txt

  A simple view controller demonstrating use of Cocoa bindings for iOS.

*/

import UIKit


class ViewController: UIViewController
  {

    dynamic var modelName: String = ""
    dynamic var modelVisible: Bool = true

    @IBOutlet var visibleSwitch: UISwitch!
    @IBOutlet var nameContainer: UIView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var palindromeContainer: UIView!
    @IBOutlet var palindromeField : UITextField!


    override func viewDidLoad()
      {
        assert(visibleSwitch != nil && nameContainer != nil && nameField != nil && palindromeContainer != nil && palindromeField != nil, "unconnected outlets")

        super.viewDidLoad()
      }


    override func viewWillAppear(_ animated: Bool)
      {
        super.viewWillAppear(animated)

        // Bind the 'on' property of the visibility switch to the model's visible property.
        visibleSwitch.bind("on", toObject:self, withKeyPath:"modelVisible", options:nil)

        // Bind the 'hidden' property of the name and palindrome views to  model's visible property, negated.
        for component in [nameContainer, palindromeContainer] as [UIView] {
          component.bind("hidden", toObject:self, withKeyPath:"modelVisible", options:[
              NSValueTransformerNameBindingOption: (NSValueTransformerName.negateBooleanTransformerName as AnyObject),
            ])
        }

        // Bind the value of the name field to the model's name.
        nameField.bind("text", toObject:self, withKeyPath:"modelName", options:nil)

        // Bind the value of the palindrome field to the model name, using a value transformer to construct the palindrome.
        palindromeField.bind("text", toObject:self, withKeyPath:"modelName", options:[
            NSValueTransformerBindingOption: ValueTransformer.withForwardBlock({
                guard let name = $0 as? String else { fatalError("unexpected") }
                return "\(name)\(String(name.characters.reversed()))" as AnyObject
              }),
          ])
      }


    override func viewDidDisappear(_ animated: Bool)
      {
        super.viewDidDisappear(animated)

        // Teardown the previously established bindings.
        for component in [nameContainer, palindromeContainer] as [UIView] {
          component.unbind("hidden")
        }
        nameField.unbind("value")
        palindromeField.unbind("value")
      }

  }
