//
//  AlbumsDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-08.
//
//

import UIKit
import Photos

internal class AlbumsDataSource: NSObject, UITableViewDataSource {
    internal var selectedAlbum: PHAssetCollection
    
    private var albums: [PHAssetCollection] = []
    private let albumCellIdentifier = "albumCell"
    
    override init() {
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
        } else {
            // To guarantee that we have a selected album. This should never happen
            selectedAlbum = PHAssetCollection()
        }
        
        super.init()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
        
        // Selection checkmark
        if album == selectedAlbum {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
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
                        stop.initialize(true)
                    }
                }
            }
        }
        
        return cell
    }
}
