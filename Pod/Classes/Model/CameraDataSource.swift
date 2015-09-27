//
//  CameraDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-09-26.
//
//

import UIKit

final class CameraDataSource: NSObject, UICollectionViewDataSource {
    let cameraCellIdentifier = "cameraCellIdentifier"
    let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Int(cameraAvailable)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(cameraAvailable)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(cameraCellIdentifier, forIndexPath: indexPath)
    }
}
