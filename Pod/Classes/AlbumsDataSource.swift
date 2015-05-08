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
    private var albums: [PHAssetCollection] = []
    private let albumCellIdentifier = "albumCell"
    
    override init() {
        super.init()
        
        let fetchOptions = PHFetchOptions()
        
        if let result = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: fetchOptions) {
            result.enumerateObjectsUsingBlock { (object, idx, _) in
                if let album = object as? PHAssetCollection {
                    self.albums.append(album)
                }
            }
        }
        
        if let result = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions) {
            result.enumerateObjectsUsingBlock { (object, idx, _) in
                if let album = object as? PHAssetCollection {
                    self.albums.append(album)
                }
            }
        }
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
