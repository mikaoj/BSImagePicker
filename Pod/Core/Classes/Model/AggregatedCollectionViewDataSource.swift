//
//  AggregatedCollectionViewDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-07-28.
//
//

import Foundation

class AggregatedCollectionViewDataSource<T: UICollectionViewDataSource> : NSObject, UICollectionViewDataSource {
    let dataSources: [T]
    
    init(dataSources: [T]) {
        self.dataSources = dataSources
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSources.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources[section].collectionView(collectionView, numberOfItemsInSection: 0)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return dataSources[indexPath.section].collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: indexPath.item, inSection: 0))
    }
}
