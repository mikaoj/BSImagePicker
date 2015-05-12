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

internal protocol AlbumsDelegate {
    func didSelectAlbum(album: PHAssetCollection)
}

internal class AlbumsDataSource: NSObject, UITableViewDataSource {
    internal var delegate: AlbumsDelegate?
    private var selectedAlbum: PHAssetCollection {
        didSet {
            delegate?.didSelectAlbum(selectedAlbum)
        }
    }
    private var albums: [PHAssetCollection] = []
    private let albumCellIdentifier = "albumCell"
    
    init(delegate aDelegate: AlbumsDelegate?) {
        // Set delegate
        delegate = aDelegate
        
        let fetchOptions = PHFetchOptions()
        
        // Find camera roll
        var albums: [PHAssetCollection] = []
        if let result = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: fetchOptions) {
            result.enumerateObjectsUsingBlock { (object, idx, _) in
                if let album = object as? PHAssetCollection {
                    albums.append(album)
                }
            }
        }
        
        // Find all albums
        if let result = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions) {
            result.enumerateObjectsUsingBlock { (object, idx, _) in
                if let album = object as? PHAssetCollection {
                    albums.append(album)
                }
            }
        }
        
        // Set albums
        self.albums = albums
        
        // Set selected albums to be the first album (should be the camera roll)
        if let selectedAlbum = albums.first {
            self.selectedAlbum = selectedAlbum
            delegate?.didSelectAlbum(selectedAlbum)
        } else {
            // To guarantee that we have a selected album. This should never happen
            selectedAlbum = PHAssetCollection()
        }
        
        super.init()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(albumCellIdentifier, forIndexPath: indexPath) as! AlbumCell
        
        // Fetch album
        let album = albums[indexPath.row]
        
        // Title
        cell.albumTitleLabel.text = album.localizedTitle
        
        // Selected
        cell.selected = album == selectedAlbum
        
        // Selection style
        cell.selectionStyle = .None
        
        // Set images
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
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
        
        return cell
    }
    
    func selectAlbum(atIndexPath indexPath: NSIndexPath, inTableView tableView: UITableView) {
        selectedAlbum = albums[indexPath.row]
    }
}
