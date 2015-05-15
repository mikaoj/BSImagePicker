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

internal protocol PhotosDelegate {
    func didUpdateDatasource(incrementalChange: Bool, insert: [NSIndexPath], delete: [NSIndexPath], change: [NSIndexPath])
}

internal class PhotosDataSource : NSObject, UICollectionViewDataSource, AlbumsDelegate, PHPhotoLibraryChangeObserver {
    internal var imageSize: CGSize = CGSizeZero
    internal var delegate: PhotosDelegate?
    private let photoCellIdentifier = "photoCellIdentifier"
    private let photosManager = PHCachingImageManager()
    private let imageContentMode: PHImageContentMode = .AspectFill
    private var fetchResult = PHFetchResult()
    
    private var selectedPhotos: [PHAsset] = []
    
    init() {
        super.init()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    // MARK: UICollectionViewDatasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = fetchResult[indexPath.row] as? PHAsset {
            cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.imageView.image = result
                })
            
            // Set selection number
            if let index = find(selectedPhotos, asset) {
                cell.selectionNumber = index + 1
                cell.selected = true
            } else {
                cell.selectionNumber = 0
                cell.selected = false
            }
        }
        
        return cell
    }
    
    // MARK: Selection & deselection
    func selectAsset(atIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        if let asset = fetchResult[indexPath.row] as? PHAsset where contains(selectedPhotos, asset) == false {
            selectedPhotos.append(asset)
        }
        
        // Update selection number
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell {
            cell.selectionNumber = selectedPhotos.count
        }
    }
    
    func deselectAsset(atIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        if let asset = fetchResult[indexPath.row] as? PHAsset, let index = find(selectedPhotos, asset) {
            selectedPhotos.removeAtIndex(index)
        }
    }
    
    func numberOfSelectedAssets() -> Int {
        return selectedPhotos.count
    }
    
    func indexPathsForSelectedAssets() -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        
        for asset in selectedPhotos {
            let index = fetchResult.indexOfObject(asset)
            if index != NSNotFound {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                indexPaths.append(indexPath)
            }
        }
        
        return indexPaths
    }
    
    func assetAtIndexPath(indexPath: NSIndexPath) -> PHAsset {
        return fetchResult[indexPath.row] as! PHAsset
    }
    
    func selectedAssets() -> [PHAsset] {
        return selectedPhotos
    }
    
    // MARK: AlbumsDelegate
    func didSelectAlbum(album: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        
        fetchResult = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions)
        
        // Notify delegate
        delegate?.didUpdateDatasource(false, insert: [], delete: [], change: [])
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange!) {
        // Check if there are changes to our fetch result
        if let collectionChanges = changeInstance.changeDetailsForFetchResult(fetchResult) {
            // Get the new fetch result
            fetchResult = collectionChanges.fetchResultAfterChanges
            
            let removedIndexes: [NSIndexPath]
            let insertedIndexes: [NSIndexPath]
            let changedIndexes: [NSIndexPath]
            
            if collectionChanges.hasIncrementalChanges {
                // Incremental change, tell delegate what has been deleted, inserted and changed
                removedIndexes = indexPathsFromIndexSet(collectionChanges.removedIndexes, inSection: 0)
                insertedIndexes = indexPathsFromIndexSet(collectionChanges.insertedIndexes, inSection: 0)
                changedIndexes = indexPathsFromIndexSet(collectionChanges.changedIndexes, inSection: 0)
            } else {
                // No incremental change. Set empty arrays
                removedIndexes = []
                insertedIndexes = []
                changedIndexes = []
            }
            
            // Notify delegate
            delegate?.didUpdateDatasource(collectionChanges.hasIncrementalChanges, insert: insertedIndexes, delete: removedIndexes, change: changedIndexes)
        }
    }
    
    private func indexPathsFromIndexSet(indexSet: NSIndexSet, inSection section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        
        indexSet.enumerateIndexesUsingBlock { (index, _) -> Void in
            indexPaths.append(NSIndexPath(forItem: index, inSection: section))
        }
        
        return indexPaths
    }
}
