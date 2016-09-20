// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
Provides a grid collection view layout
*/
@objc(BSGridCollectionViewLayout)
public final class GridCollectionViewLayout: UICollectionViewLayout {
    /**
    Spacing between items (horizontal and vertical)
    */
    public var itemSpacing: CGFloat = 0 {
        didSet {
            itemSize = estimatedItemSize()
        }
    }

    /**
    Number of items per row
    */
    public var itemsPerRow = 3 {
        didSet {
            itemSize = estimatedItemSize()
        }
    }

    /**
    Item height ratio relative to it's width
    */
    public var itemHeightRatio: CGFloat = 1 {
        didSet {
            itemSize = estimatedItemSize()
        }
    }

    /**
    Size for each item
    */
    public private(set) var itemSize = CGSize.zero

    var items = 0
    var rows = 0

    public override func prepare() {
        // Set total number of items and rows
        items = estimatedNumberOfItems()
        rows = items / itemsPerRow + ((items % itemsPerRow > 0) ? 1 : 0)

        // Set item size
        itemSize = estimatedItemSize()
    }

    /**
     See UICollectionViewLayout documentation
     */
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView, rows > 0 else {
            return CGSize.zero
        }
        
        let height = estimatedRowHeight() * CGFloat(rows)
        return CGSize(width: collectionView.bounds.width, height: height)
    }

    /**
     See UICollectionViewLayout documentation
     */
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return indexPathsInRect(rect).map { (indexPath) -> UICollectionViewLayoutAttributes? in
            return self.layoutAttributesForItem(at: indexPath)
        }.flatMap { $0 }
    }

    /**
     See UICollectionViewLayout documentation
     */
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Guard against negative row/sections.
        guard indexPath.row >= 0, indexPath.section >= 0 else {
            return nil
        }
        
        let itemIndex = flatIndex(indexPath) // index among total number of items
        let rowIndex = itemIndex % itemsPerRow // index within it's row
        let row = itemIndex / itemsPerRow // which row for that item

        let x = (CGFloat(rowIndex) * itemSpacing) + (CGFloat(rowIndex) * itemSize.width)
        let y = (CGFloat(row) * itemSpacing) + (CGFloat(row) * itemSize.height)
        let width = itemSize.width
        let height = itemSize.height

        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.frame = CGRect(x: x, y: y, width: width, height: height)

        return attribute
    }

    /**
     See UICollectionViewLayout documentation
     */
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    // No decoration or supplementary views
    /**
    See UICollectionViewLayout documentation
    */
    public override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    /**
     See UICollectionViewLayout documentation
     */
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
}

extension GridCollectionViewLayout {
    /**
     Calculates which index paths are within a given rect
     - parameter rect: The rect which we want index paths for
     - returns: An array of indexPaths for that rect
     */
    func indexPathsInRect(_ rect: CGRect) -> [IndexPath] {
        // Make sure we have items/rows
        guard items > 0 && rows > 0 else { return [] }
        
        let rowHeight = estimatedRowHeight()
        
        let startRow = GridCollectionViewLayout.firstRowInRect(rect, withRowHeight: rowHeight)
        let endRow = GridCollectionViewLayout.lastRowInRect(rect, withRowHeight: rowHeight, max: rows)
        guard startRow <= endRow else { return [] }
        
        let startIndex = GridCollectionViewLayout.firstIndexInRow(min(startRow, endRow), withItemsPerRow: itemsPerRow)
        let endIndex = GridCollectionViewLayout.lastIndexInRow(max(startRow, endRow), withItemsPerRow: itemsPerRow, numberOfItems: items)
        
        guard startIndex <= endIndex else { return [] }
        let indexPaths = (startIndex...endIndex).map { indexPathFromFlatIndex($0) }

        return indexPaths
    }
    
    /**
     Calculates which row index would be first for a given rect.
     - parameter rect: The rect to check
     - parameter rowHeight: Height for a row
     - returns: First row index
     */
    static func firstRowInRect(_ rect: CGRect, withRowHeight rowHeight: CGFloat) -> Int {
        if rect.origin.y / rowHeight < 0 {
            return 0
        } else {
            return Int(rect.origin.y / rowHeight)
        }
    }
    
    /**
     Calculates which row index would be last for a given rect.
     - parameter rect: The rect to check
     - parameter rowHeight: Height for a row
     - returns: Last row index
     */
    static func lastRowInRect(_ rect: CGRect, withRowHeight rowHeight: CGFloat, max: Int) -> Int {
        guard rect.size.height >= rowHeight else { return 0 }
        
        if (rect.origin.y + rect.height) / rowHeight > CGFloat(max) {
            return max - 1
        } else {
            return Int(ceil((rect.origin.y + rect.height) / rowHeight)) - 1
        }
    }
    
    /**
     Calculates which index would be the first for a given row.
     - parameter row: Row index
     - parameter itemsPerRow: How many items there can be in a row
     - returns: First index
     */
    static func firstIndexInRow(_ row: Int, withItemsPerRow itemsPerRow: Int) -> Int {
        return row * itemsPerRow
    }
    
    /**
     Calculates which index would be the last for a given row.
     - parameter row: Row index
     - parameter itemsPerRow: How many items there can be in a row
     - parameter numberOfItems: The total number of items.
     - returns: Last index
     */
    static func lastIndexInRow(_ row: Int, withItemsPerRow itemsPerRow: Int, numberOfItems: Int) -> Int {
        let maxIndex = (row + 1) * itemsPerRow - 1
        let bounds = numberOfItems - 1
        
        if maxIndex > bounds {
            return bounds
        } else {
            return maxIndex
        }
    }

    /**
     Takes an index path (which are 2 dimensional) and turns it into a 1 dimensional index
     - parameter indexPath: The index path we want to flatten
     - returns: A flat index
     */
    func flatIndex(_ indexPath: IndexPath) -> Int {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return (0..<(indexPath as NSIndexPath).section).reduce((indexPath as NSIndexPath).row) { $0 + collectionView.numberOfItems(inSection: $1)}
    }

    /**
     Converts a flat index into an index path
     - parameter index: The flat index
     - returns: An index path
     */
    func indexPathFromFlatIndex(_ index: Int) -> IndexPath {
        guard let collectionView = collectionView else {
            return IndexPath(item: 0, section: 0)
        }

        var item = index
        var section = 0

        while(item >= collectionView.numberOfItems(inSection: section)) {
            item -= collectionView.numberOfItems(inSection: section)
            section += 1
        }

        return IndexPath(item: item, section: section)
    }

    /**
     Estimated the size of the items
     - returns: Estimated item size
     */
    func estimatedItemSize() -> CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }

        let itemWidth = (collectionView.bounds.width - CGFloat(itemsPerRow - 1) * itemSpacing) / CGFloat(itemsPerRow)
        return CGSize(width: itemWidth, height: itemWidth * itemHeightRatio)
    }

    /**
     Estimated total number of items
     - returns: Total number of items
     */
    func estimatedNumberOfItems() -> Int {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return (0..<collectionView.numberOfSections).reduce(0, {$0 + collectionView.numberOfItems(inSection: $1)})
    }

    /**
     Height for each row
     - returns: Row height
     */
    func estimatedRowHeight() -> CGFloat {
        return itemSize.height+itemSpacing
    }
}
