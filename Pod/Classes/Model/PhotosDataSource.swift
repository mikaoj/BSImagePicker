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
    func didUpdatePhotos()
}

internal class PhotosDataSource : NSObject, UICollectionViewDataSource, AlbumsDelegate {
    internal var imageSize: CGSize = CGSizeZero
    internal var delegate: PhotosDelegate?
    private let photoCellIdentifier = "photoCellIdentifier"
    private let photosManager = PHCachingImageManager()
    private let imageContentMode: PHImageContentMode = .AspectFill
    private var photos: [PHAsset] = [] {
        didSet {
            delegate?.didUpdatePhotos()
        }
    }
    
    private var selectedPhotos: [PHAsset] = []
    
    // MARK: UICollectionViewDatasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        let asset = photos[indexPath.row]
        cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
            cell.imageView.image = result
        })
        
        // Set selection number
        if let index = find(selectedPhotos, asset) {
            cell.selectionNumber = index
        }
        
        return cell
    }
    
    // MARK: Selection & deselection
    func selectAsset(atIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        let asset = photos[indexPath.row]
        if contains(selectedPhotos, asset) == false {
            selectedPhotos.append(asset)
        }
        
        // Update selection number
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell {
            cell.selectionNumber = selectedPhotos.count
        }
    }
    
    func deselectAsset(atIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
        let asset = photos[indexPath.row]
        if let index = find(selectedPhotos, asset) {
            selectedPhotos.removeAtIndex(index)
        }
    }
    
    // MARK: AlbumsDelegate
    func didSelectAlbum(album: PHAssetCollection) {
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
                }
            }
            
            photos = assets
        }
    }
}
