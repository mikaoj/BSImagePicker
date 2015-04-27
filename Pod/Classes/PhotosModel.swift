//
//  ImagePickerModel.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-04-26.
//
//

import UIKit

internal class PhotosModel : NSObject, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
