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

/**
Gives UICollectionViewDataSource functionality with a given data source and cell factory
*/
final class PhotoCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    var selections = [PHAsset]()
    var fetchResult: PHFetchResult<PHAsset>
    
    fileprivate let photoCellIdentifier = "photoCellIdentifier"
    fileprivate let photosManager = PHCachingImageManager.default()
    fileprivate let imageContentMode: PHImageContentMode = .aspectFill
    
    let settings: BSImagePickerSettings?
    var imageSize: CGSize = CGSize.zero
    
  init(fetchResult: PHFetchResult<PHAsset>, selections: PHFetchResult<PHAsset>? = nil, settings: BSImagePickerSettings?) {
        self.fetchResult = fetchResult
        self.settings = settings
        if let selections = selections {
            var selectionsArray = [PHAsset]()
            selections.enumerateObjects({ (asset, idx, stop) in
                selectionsArray.append(asset)
            })
            
            self.selections = selectionsArray
        }
    
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UIView.setAnimationsEnabled(false)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! PhotoCell
        cell.accessibilityIdentifier = "photo_cell_\(indexPath.item)"
        if let settings = settings {
            cell.settings = settings
        }
        
        let asset = fetchResult[indexPath.row]
        cell.asset = asset
        
        var options = PHImageRequestOptions()
        options.resizeMode = .fast
        
        var size: CGSize
        let imageRatio = (CGFloat(asset.pixelWidth)) / (CGFloat(asset.pixelHeight))
        let screenScale = UIScreen.main.scale
        if asset.pixelWidth > asset.pixelHeight {
            size = CGSize(width: cell.frame.size.height * imageRatio * screenScale, height: cell.frame.size.height)
        }
        else {
            size = CGSize(width: cell.frame.size.width, height: cell.frame.size.width * screenScale / imageRatio)
        }
        
        let cellIdx = indexPath.row
        
        // Cancel any pending image requests
        if cell.tag != cellIdx, cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        cell.tag = cellIdx
        
        // Request image
        photosManager.requestImage(for: asset, targetSize: size, contentMode: imageContentMode, options: options) { (result, _) in
            let appropriate = (cell.tag == cellIdx)
            if appropriate {
                cell.imageView.image = result
            }
        }
        
        // Set selection number
        if let index = selections.index(of: asset) {
            if let character = settings?.selectionCharacter {
                cell.selectionString = String(character)
            } else {
                cell.selectionString = String(index+1)
            }
            
            cell.photoSelected = true
        } else {
            cell.photoSelected = false
        }
        
        UIView.setAnimationsEnabled(true)
        
        return cell
    }
    
    func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(UINib(nibName: "PhotoCell", bundle: BSImagePickerViewController.bundle), forCellWithReuseIdentifier: photoCellIdentifier)
    }
}
