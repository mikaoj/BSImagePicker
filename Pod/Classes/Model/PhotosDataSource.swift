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

final class PhotosDataSource : NSObject, UICollectionViewDataSource, AssetsDelegate, Selectable, PHPhotoLibraryChangeObserver {
    var imageSize: CGSize = CGSizeZero
    var delegate: AssetsDelegate?
    subscript (idx: Int) -> PHFetchResult {
        return _assetsModel[idx]
    }
    
    private let photoCellIdentifier = "photoCellIdentifier"
    private let photosManager = PHCachingImageManager()
    private let imageContentMode: PHImageContentMode = .AspectFill
    private var _assetsModel: AssetsModel<PHAsset>
    private let settings: BSImagePickerSettings
    
    required init(settings: BSImagePickerSettings) {
        self.settings = settings
        _assetsModel = AssetsModel(fetchResult: [])
        
        super.init()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    // MARK: UICollectionViewDatasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return _assetsModel.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _assetsModel[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        UIView.setAnimationsEnabled(false)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        cell.settings = settings
        
        // Cancel any pending image requests
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = _assetsModel[indexPath.section][indexPath.row] as? PHAsset {
            cell.asset = asset
            
            // Request image
            cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.imageView.image = result
                })
            
            // Set selection number
            if let index = find(_assetsModel.selections(), asset) {
                if let character = settings.selectionCharacter {
                    cell.selectionString = String(character)
                } else {
                    cell.selectionString = String(index + 1)
                }
                
                cell.selected = true
            } else {
                cell.selected = false
            }
        }
        
        UIView.setAnimationsEnabled(true)
        
        return cell
    }
    
    // MARK: AssetsDelegate
    func didUpdateAssets(sender: AnyObject, incrementalChange: Bool, insert: [NSIndexPath], delete: [NSIndexPath], change: [NSIndexPath]) {
        self.delegate?.didUpdateAssets(self, incrementalChange: incrementalChange, insert: insert, delete: delete, change: change)
    }

    func fetchResultsForAsset(album: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions)
        let temporarySelection = _assetsModel.selections()
        _assetsModel = AssetsModel(fetchResult: [fetchResult])
        _assetsModel.delegate = self
        _assetsModel.setSelections(temporarySelection)
        
        delegate?.didUpdateAssets(self, incrementalChange: false, insert: [], delete: [], change: [])
    }
    
    // MARK: Selectable
    func selectObjectAtIndexPath(indexPath: NSIndexPath) {
        _assetsModel.selectObjectAtIndexPath(indexPath)
    }
    
    func deselectObjectAtIndexPath(indexPath: NSIndexPath) {
        _assetsModel.deselectObjectAtIndexPath(indexPath)
    }
    
    func selectionCount() -> Int {
        return _assetsModel.selectionCount()
    }
    
    func selectedIndexPaths() -> [NSIndexPath] {
        return _assetsModel.selectedIndexPaths()
    }
    
    func selections() -> [PHAsset] {
        return _assetsModel.selections()
    }
    
    // PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange!) {
        _assetsModel.photoLibraryDidChange(changeInstance)
    }
}
