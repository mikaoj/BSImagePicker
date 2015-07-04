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

final class AlbumsDataSource: NSObject, UITableViewDataSource, AssetsDelegate, Selectable, PHPhotoLibraryChangeObserver {
    var delegate: AssetsDelegate?
    
    private var _assetsModel: AssetsModel<PHAssetCollection>
    private let albumCellIdentifier = "albumCell"
    
    override init() {
        let fetchOptions = PHFetchOptions()
        
        // Camera roll fetch result
        let cameraRollResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: fetchOptions)
        
        // Albums fetch result
        let albumResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        _assetsModel = AssetsModel(fetchResult: [cameraRollResult, albumResult])
        
        super.init()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _assetsModel.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _assetsModel[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(albumCellIdentifier, forIndexPath: indexPath) as! AlbumCell
        
        // Fetch album
        if let album = _assetsModel[indexPath.section][indexPath.row] as? PHAssetCollection {
            // Title
            cell.albumTitleLabel.text = album.localizedTitle
            
            // Selected
            cell.selected = contains(_assetsModel.selections(), album)
            
            // Selection style
            cell.selectionStyle = .None
            
            // Set images
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            // TODO: Limit result to 3 images
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            
            PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions)
            if let result = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions) {
                result.enumerateObjectsUsingBlock { (object, idx, stop) in
                    if let asset = object as? PHAsset {
                        let imageSize = CGSize(width: 79, height: 79)
                        let imageContentMode: PHImageContentMode = .AspectFill
                        switch idx {
                        case 0:
                            PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                                cell.firstImageView.image = result
                                cell.secondImageView.image = result
                                cell.thirdImageView.image = result
                            }
                        case 1:
                            PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                                cell.secondImageView.image = result
                                cell.thirdImageView.image = result
                            }
                        case 2:
                            PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                                cell.thirdImageView.image = result
                            }
                            
                        default:
                            // Stop enumeration
                            stop.initialize(true)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: AssetsDelegate
    func didUpdateAssets(sender: AnyObject, incrementalChange: Bool, insert: [NSIndexPath], delete: [NSIndexPath], change: [NSIndexPath]) {
        delegate?.didUpdateAssets(self, incrementalChange: incrementalChange, insert: insert, delete: delete, change: change)
    }
    
    // MARK: Selectable
    func selectObjectAtIndexPath(indexPath: NSIndexPath) {
        // Only 1 selection allowed, so clear old selection
        _assetsModel.removeSelections()
        
        // Selection new object
        _assetsModel.selectObjectAtIndexPath(indexPath)
    }
    
    func deselectObjectAtIndexPath(indexPath: NSIndexPath) {
        // No deselection allowed
    }
    
    func selectionCount() -> Int {
        return _assetsModel.selectionCount()
    }
    
    func selectedIndexPaths() -> [NSIndexPath] {
        return _assetsModel.selectedIndexPaths()
    }
    
    func selections() -> [PHAssetCollection] {
        return _assetsModel.selections()
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange!) {
        _assetsModel.photoLibraryDidChange(changeInstance)
    }
}
