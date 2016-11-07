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
          }

        override func transformedValue(value : AnyObject?) -> AnyObject?
          { return forwardBlock(value) }

        override class func allowsReverseTransformation() -> Bool
          { return false; }
      }


    public class func withForwardBlock(forward: AnyObject? -> AnyObject?) -> NSValueTransformer
      {
        // Return a one-directional NSValueTransformer which uses the given block as its transformation.

        return BlockValueTransformer(forwardBlock: forward)
      }


    private class ReversibleBlockValueTransformer: NSValueTransformer
      {
        let forwardBlock: AnyObject? -> AnyObject?
        let reverseBlock: AnyObject? -> AnyObject?

        init(forwardBlock fwd: AnyObject? -> AnyObject?, reverseBlock rev: AnyObject? -> AnyObject?)
          {
            forwardBlock = fwd
            reverseBlock = rev
          }

        override func transformedValue(value : AnyObject?) -> AnyObject?
          { return forwardBlock(value) }

        override class func allowsReverseTransformation() -> Bool
          { return true; }

        override func reverseTransformedValue(value: AnyObject?) -> AnyObject?
          { return reverseBlock(value) }
      }


    public class func withForwardBlock(fwd: AnyObject? -> AnyObject?, reverseBlock rev: AnyObject? -> AnyObject?) -> NSValueTransformer
      {
        // Return a bi-directional NSValueTransformer using the given blocks as forward and reverse transformations.

        return ReversibleBlockValueTransformer(forwardBlock: fwd, reverseBlock: rev)
      }

  }
