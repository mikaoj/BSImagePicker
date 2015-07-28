//
//  PHFetchResult+UITableViewDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-07-28.
//
//

import Foundation
import Photos

extension PHFetchResult : UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return AlbumCellFactory.cellForIndexPath(indexPath, withObject: objectAtIndex(indexPath.row), inTableView: tableView)
    }
}
