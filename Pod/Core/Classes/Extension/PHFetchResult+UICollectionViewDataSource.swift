//
//  PHFetchResult+UICollectionViewDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-07-28.
//
//

import Foundation
import Photos

extension PHFetchResult : UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return PhotoCellFactory.cellForIndexPath(indexPath, withObject: objectAtIndex(indexPath.row), inCollectionView: collectionView)
    }
}
