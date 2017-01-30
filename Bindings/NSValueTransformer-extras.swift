/*

  Copyright (c) 2016 David Spooner; see License.txt

  Methods added to NSValueTransformer.

*/

import Foundation


public extension ValueTransformer
  {

    fileprivate class BlockValueTransformer: ValueTransformer
      {
        let forwardBlock: (AnyObject?) -> AnyObject?

        init(forwardBlock forward: @escaping (AnyObject?) -> AnyObject?)
          {
            forwardBlock = forward
          }

        override func transformedValue(_ value : Any?) -> Any?
          { return forwardBlock(value as AnyObject?) }

        override class func allowsReverseTransformation() -> Bool
          { return false; }
      }


    public class func withForwardBlock(_ forward: @escaping (AnyObject?) -> AnyObject?) -> ValueTransformer
      {
        // Return a one-directional NSValueTransformer which uses the given block as its transformation.

        return BlockValueTransformer(forwardBlock: forward)
      }


    fileprivate class ReversibleBlockValueTransformer: ValueTransformer
      {
        let forwardBlock: (AnyObject?) -> AnyObject?
        let reverseBlock: (AnyObject?) -> AnyObject?

        init(forwardBlock fwd: @escaping (AnyObject?) -> AnyObject?, reverseBlock rev: @escaping (AnyObject?) -> AnyObject?)
          {
            forwardBlock = fwd
            reverseBlock = rev
          }

        override func transformedValue(_ value : Any?) -> Any?
          { return forwardBlock(value as AnyObject?) }

        override class func allowsReverseTransformation() -> Bool
          { return true; }

        override func reverseTransformedValue(_ value: Any?) -> Any?
          { return reverseBlock(value as AnyObject?) }
      }


    public class func withForwardBlock(_ fwd: @escaping (AnyObject?) -> AnyObject?, reverseBlock rev: @escaping (AnyObject?) -> AnyObject?) -> ValueTransformer
      {
        // Return a bi-directional NSValueTransformer using the given blocks as forward and reverse transformations.

        return ReversibleBlockValueTransformer(forwardBlock: fwd, reverseBlock: rev)
      }

  }
