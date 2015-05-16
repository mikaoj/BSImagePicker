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

internal class PhotosDataSource : NSObject, UICollectionViewDataSource, AlbumsDelegate {
    internal var imageSize: CGSize = CGSizeZero
    internal var delegate: FetchResultDelegate? {
        set {
            selectableFetchResult.delegate = newValue
        }
        
        get {
            return selectableFetchResult.delegate
        }
    }
    internal var selectableFetchResult: SelectableFetchResultModel<PHAsset> {
        get {
            return _selectableFetchResult
        }
    }
    
    private let photoCellIdentifier = "photoCellIdentifier"
    private let photosManager = PHCachingImageManager()
    private let imageContentMode: PHImageContentMode = .AspectFill
    private var _selectableFetchResult: SelectableFetchResultModel<PHAsset>
    
    override init() {
        _selectableFetchResult = SelectableFetchResultModel<PHAsset>(fetchResult: PHFetchResult())
    }
    
    // MARK: UICollectionViewDatasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectableFetchResult.fetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = selectableFetchResult.fetchResult[indexPath.row] as? PHAsset {
            cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.imageView.image = result
                })
            
            // Set selection number
            if let index = find(selectableFetchResult.selectedResults, asset) {
                cell.selectionNumber = index + 1
                cell.selected = true
            } else {
                cell.selectionNumber = 0
                cell.selected = false
            }
        }
        
        return cell
    }

    // MARK: AlbumsDelegate
    func didSelectAlbum(album: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions)
        let localDelegate = delegate
        _selectableFetchResult = SelectableFetchResultModel<PHAsset>(fetchResult: fetchResult)
        selectableFetchResult.delegate = localDelegate
        
        // Notify delegate
        delegate?.didUpdateFetchResult(false, insert: [], delete: [], change: [])
    }
}
