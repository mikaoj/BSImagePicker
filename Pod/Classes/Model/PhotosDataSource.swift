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
import Photos

internal class PhotosDataSource : NSObject, UICollectionViewDataSource {
    internal var album: PHAssetCollection? {
        didSet {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            
            PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions)
            if let result = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions) {
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
        }
    }
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
    private var assets: [PHAsset] = [] {
        willSet {
            stopCaching()
        }
        didSet {
            startCaching()
        }
    }
    
    private var selectedAssets: [PHAsset] = []
    
    deinit {
//        photosManager.stopCachingImagesForAllAssets()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        let asset = assets[indexPath.row]
        cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
            cell.imageView.image = result
        })
        
        // Set selection number
        if let index = find(selectedAssets, asset) {
            cell.selectionNumber = index
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
    
    func selectAsset(atIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        let asset = assets[indexPath.row]
        selectedAssets.append(asset)
        
        // Update selection number
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell {
            cell.selectionNumber = selectedAssets.count
        }
    }
    
    func deselectAsset(atIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        let asset = assets[indexPath.row]
        if let index = find(selectedAssets, asset) {
            selectedAssets.removeAtIndex(index)
        }
    }
}
