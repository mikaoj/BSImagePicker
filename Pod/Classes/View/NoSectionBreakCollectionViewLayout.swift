//
//  NoSectionCollectionViewLayout.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-09-27.
//
//

import UIKit

/*
Displays multiple sections on the same row
*/
class NoSectionBreakCollectionViewLayout: UICollectionViewFlowLayout {
    var cellsPerRow: Int = 0
    
    override func collectionViewContentSize() -> CGSize {
        guard let collectionView = collectionView else {
            return CGSizeZero
        }
        
        // Sum total number of items
        let sections = collectionView.numberOfSections()
        var items = 0
        for var i = 0; i < sections; i++ {
            items += collectionView.numberOfItemsInSection(i)
        }
        
        let rows = items / cellsPerRow
        
        let height = CGFloat(rows) * itemSize.height + (minimumLineSpacing * CGFloat(rows))
        
        return CGSizeMake(collectionView.bounds.width, height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Let super do its calculation
        guard let attributes = super.layoutAttributesForElementsInRect(rect), let collectionWidth = collectionView?.bounds.width else {
            return nil
        }
        
        var previousAttribute: UICollectionViewLayoutAttributes?
        
        // Oh my god how ugly this is :o
        var myAttributes = [UICollectionViewLayoutAttributes]()
        let spacing = (CGFloat(cellsPerRow) * minimumInteritemSpacing) / CGFloat(cellsPerRow-1)
        for tmp in attributes {
            let next = tmp.copy() as! UICollectionViewLayoutAttributes
            if let previous = previousAttribute {
                // Check if next fits to the right of previous
                if (previous.frame.origin.x + previous.frame.width + next.frame.width + spacing) <= collectionWidth {
                    next.frame = CGRectMake(previous.frame.origin.x + previous.frame.width + spacing, previous.frame.origin.y, next.frame.width, next.frame.height)
                } else { // If not, break row
                    next.frame = CGRectMake(0, previous.frame.origin.y + previous.frame.height + minimumLineSpacing, next.frame.width, next.frame.height)
                }
            }
            
            previousAttribute = next
            
            myAttributes.append(next)
        }
        
        return myAttributes
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
}
