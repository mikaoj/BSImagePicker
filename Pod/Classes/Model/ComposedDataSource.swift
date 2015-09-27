//
//  ComposedDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-09-26.
//
//

import UIKit

/**
Takes multiple UICollectionViewDataSources and joins them into one section
*/
class ComposedDataSource: NSObject, UICollectionViewDataSource {
    let dataSources: [UICollectionViewDataSource]
    
    init(dataSources: [UICollectionViewDataSource]) {
        self.dataSources = dataSources
        
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1 // Always one section, no mather how many data sources we have
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.reduce(0, combine: { (count, dataSource) -> Int in
            return dataSource.collectionView(collectionView, numberOfItemsInSection: 0) + count
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Ask the correct data source for the cell
        // THIS IS REALLY UGLY...refactor pleeeeeaaaaase!
        // A custom collection view layout would probably allow multiple sections to appear on the same row...
        var cell: UICollectionViewCell!
        var previousCount = 0
        for dataSource in dataSources {
            let sourceIndex = indexPath.row - previousCount
            let sourceCount = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
            
            if sourceIndex < sourceCount {
                cell = dataSource.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forRow: sourceIndex, inSection: 0))
                break
            }
            
            previousCount += sourceCount
        }
        
        return cell
    }
}
