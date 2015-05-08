//
//  ImagePickerModel.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-04-26.
//
//

import UIKit
import Photos

internal class PhotosDataSource : NSObject, UICollectionViewDataSource {
    internal var imageSize: CGSize? {
        willSet { stopCaching() }
        didSet { startCaching() }
    }
    
    private let photoCellIdentifier = "photoCellIdentifier"
    private let photosManager = PHCachingImageManager()
    private let imageContentMode: PHImageContentMode = .AspectFill
    private var assets: [PHAsset] = [] {
        willSet { stopCaching() }
        didSet { startCaching() }
    }
    
    override init() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        if let results = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions) {
            var assets: [PHAsset] = []
            results.enumerateObjectsUsingBlock { (object, idx, _) in
                if let asset = object as? PHAsset {
                    assets.append(asset)
                }
            }
            
            self.assets = assets
        }
        
        super.init()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let imageSize = imageSize {
            let asset = assets[indexPath.row]
            cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.imageView.image = result
                })
        }
        
        return cell
    }
    
    private func stopCaching() {
        photosManager.stopCachingImagesForAllAssets()
    }
    
    private func startCaching() {
        if let imageSize = imageSize {
            photosManager.startCachingImagesForAssets(self.assets, targetSize: imageSize, contentMode: imageContentMode, options: nil)
        }
    }
}
