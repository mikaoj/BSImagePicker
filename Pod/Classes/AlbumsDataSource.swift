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
        let cell = tableView.dequeueReusableCellWithIdentifier(albumCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let album = albums[indexPath.row]
        cell.textLabel!.text = album.localizedTitle
        
        return cell
    }
}
