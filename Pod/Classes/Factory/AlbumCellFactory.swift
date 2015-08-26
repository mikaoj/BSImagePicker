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
Cell factory for albums
*/
final class AlbumCellFactory : TableViewCellFactory {
    private let albumCellIdentifier = "albumCell"
    
    func cellForIndexPath(indexPath: NSIndexPath, withDataSource dataSource: SelectableDataSource, inTableView tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(albumCellIdentifier, forIndexPath: indexPath) as! AlbumCell
        let cachingManager = PHCachingImageManager.defaultManager() as! PHCachingImageManager
        cachingManager.allowsCachingHighQualityImages = false
        
        // Fetch album
        if let album = dataSource.objectAtIndexPath(indexPath) as? PHAssetCollection {
            // Title
            cell.albumTitleLabel.text = album.localizedTitle
            
            // Selected
            cell.selected = dataSource.isObjectAtIndexPathSelected(indexPath)
            
            // Selection style
            cell.selectionStyle = .None
            
            // Set images
            let imageSize = CGSize(width: 79, height: 79)
            let imageContentMode: PHImageContentMode = .AspectFill
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            
            if let result :PHFetchResult = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions) {
                if (result.count == 0) {
                    cell.firstImageView.image = nil
                    cell.secondImageView.image = nil
                    cell.thirdImageView.image = nil
                    return cell
                } else if (result.count == 1) {
                    if let asset = result.firstObject as? PHAsset {
                        cachingManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                            cell.firstImageView.image = result
                            cell.secondImageView.image = nil
                            cell.thirdImageView.image = nil
                        }
                    }
                } else if (result.count == 2) {
                    if let asset1 = result.firstObject as? PHAsset {
                        cachingManager.requestImageForAsset(asset1, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                            cell.firstImageView.image = result
                        }
                    }
                    if let asset2 = result.lastObject as? PHAsset {
                        cachingManager.requestImageForAsset(asset2, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                            cell.secondImageView.image = result
                        }
                    }
                    cell.thirdImageView.image = nil
                } else {
                    let indexes = NSIndexSet(indexesInRange: NSMakeRange(0, 3))
                    result.enumerateObjectsAtIndexes(indexes, options: nil, usingBlock: { (object, idx, stop) in
                        switch idx {
                        case 0:
                            if let asset = object as? PHAsset {
                                cachingManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                                    cell.firstImageView.image = result
                                }
                            }
                        case 1:
                            if let asset = object as? PHAsset {
                                cachingManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                                    cell.secondImageView.image = result
                                }
                            }
                        case 2:
                            if let asset = object as? PHAsset {
                                cachingManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                                    cell.thirdImageView.image = result
                                }
                            }
                        default:
                            break
                        }
                    })
                }
            }
        }
        
        return cell
    }
}