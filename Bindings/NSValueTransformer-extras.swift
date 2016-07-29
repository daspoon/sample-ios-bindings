/*

  Copyright (c) 2016 David Spooner; see License.txt

  Methods added to NSValueTransformer.

*/

import Foundation


public extension NSValueTransformer
  {

    private class BlockValueTransformer: NSValueTransformer
      {
        let forwardBlock: AnyObject? -> AnyObject?

        init(forwardBlock forward: AnyObject? -> AnyObject?)
          {
            forwardBlock = forward
            super.init()
          }

        override func transformedValue(value : AnyObject?) -> AnyObject?
          { return forwardBlock(value) }
      }


    public class func withForwardBlock(forward: AnyObject? -> AnyObject?) -> NSValueTransformer
      {
        // Return a one-directional NSValueTransformer which uses the given block as its transformation.

        return BlockValueTransformer(forwardBlock: forward)
      }

  }
