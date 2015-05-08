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
    internal var imageSize: CGSize = CGSize(width: 0, height: 0) {
        willSet {
            if CGSizeEqualToSize(newValue, imageSize) == false {
                stopCaching()
            }
        }
        didSet {
            if CGSizeEqualToSize(oldValue, imageSize) == false {
                startCaching()
            }
        }
    }
    
    private let photoCellIdentifier = "photoCellIdentifier"
    private let photosManager = PHCachingImageManager()
    private let imageContentMode: PHImageContentMode = .AspectFill
    private var assets: [PHAsset]? {
        willSet {
            stopCaching()
        }
        didSet {
            startCaching()
        }
    }
    
    override init() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        if let result = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions) {
            var assets: [PHAsset] = []
            result.enumerateObjectsUsingBlock { (object, idx, _) in
                if let asset = object as? PHAsset {
                    assets.append(asset)
                } else {
                    println("not!")
                }
            }
            
            self.assets = assets
        }
        
        super.init()
    }
    
    deinit {
//        photosManager.stopCachingImagesForAllAssets()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let assets = assets {
            return assets.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let assets = assets {
            let asset = assets[indexPath.row]
            cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.imageView.image = result
            })
        }
        
        return cell
    }
    
    private func stopCaching() {
//        if let assets = assets {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//                self.photosManager.stopCachingImagesForAssets(assets, targetSize: self.imageSize, contentMode: self.imageContentMode, options: nil)
//            }
//        }
    }
    
    private func startCaching() {
//        if let assets = assets {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//                self.photosManager.startCachingImagesForAssets(assets, targetSize: self.imageSize, contentMode: self.imageContentMode, options: nil)
//            }
//        }
    }
}
